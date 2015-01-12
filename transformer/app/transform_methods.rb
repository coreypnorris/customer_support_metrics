def truncate_tables
  begin
    puts "truncate_tables started at #{Time.now}"
    Person.destroy_all
    Tag.destroy_all
    ConversationTag.destroy_all
    ConversationThread.destroy_all
    ConversationMetric.destroy_all
    Conversation.destroy_all
    puts "truncate_tables ended at #{Time.now}"
  rescue => e
    puts "------------------------------------------------------------------------------------------rescuing truncate_tables"
    puts "Exception at #{Time.now}"
    puts e
    puts e.backtrace
    puts "------------------------------------------------------------------------------------------rescued truncate_tables"
  end
end

def transform_helpscout_mailbox_data(mailbox_id)
  current_page = 1
  begin
    auth = {:username => ENV['HELPSCOUT_USERNAME'], :password => ENV['HELPSCOUT_PASSWORD']}
    page_of_conversations = HTTParty.get("https://api.helpscout.net/v1/mailboxes/#{mailbox_id}/conversations.json?page=#{current_page}", :basic_auth => auth)

    page_of_conversations['items'].each do |item|
      conversation = get_helpscout_conversation_by_id(item['id'])
      transform_helpscout_conversation(conversation)
    end

    current_page += 1
  rescue => e
    puts "------------------------------------------------------------------------------------------rescuing get_conversation_ids(#{mailbox_id})"
    puts "Exception at #{Time.now}"
    puts e
    puts e.backtrace
    puts "------------------------------------------------------------------------------------------rescued get_conversation_ids(#{mailbox_id})"
  end while (current_page <= page_of_conversations['pages'].to_i)
end

def get_helpscout_conversation_by_id(id)
  begin
    auth = {:username => ENV['HELPSCOUT_USERNAME'], :password => ENV['HELPSCOUT_PASSWORD']}
    conversation = HTTParty.get("https://api.helpscout.net/v1/conversations/#{id}.json", :basic_auth => auth)

    return conversation['item']
  rescue => e
    puts "------------------------------------------------------------------------------------------rescuing get_conversation_by_id(#{id})"
    puts "Exception at #{Time.now}"
    puts e
    puts e.backtrace
    puts "------------------------------------------------------------------------------------------rescued get_conversation_by_id(#{id})"
  end
end

def save_conversation_tag(saved_conversation, tag)
  Tag.create(:name => tag)
  saved_tag = Tag.find_by_name(tag)

  unless saved_conversation.tags.include? saved_tag
    saved_conversation.tags << saved_tag
  end
end

def save_conversation_person(saved_conversation, person, kind)
  Person.create(:id => person.try(:[], 'id'),
  :first_name => person.try(:[], 'firstName'),
  :last_name => person.try(:[], 'lastName'),
  :email => person.try(:[], 'email'),
  :phone => person.try(:[], 'phone'),
  :person_type => person.try(:[], 'type'))

  saved_person = Person.find_by_id(person.try(:[], 'id'))

  case kind
  when 'owner'
    saved_person.owned_conversations << saved_conversation
  when 'customer'
    saved_person.customer_conversations << saved_conversation
  when 'createdBy'
    saved_person.created_conversations << saved_conversation
  else
    saved_person.closed_conversations << saved_conversation
  end
end

def save_conversation_thread(saved_conversation, thread)
  ConversationThread.create(:id => thread.try(:[], 'id'),
  :thread_type => thread.try(:[], 'type'),
  :status => thread.try(:[], 'status'),
  :created_at => thread.try(:[], 'createdAt'),
  :opened_at => thread.try(:[], 'openedAt'),
  :source => thread.try(:[], 'source').try(:values).try(:join, ' via '),
  :action_type => thread.try(:[], 'actionType'),
  :action_source_id => thread.try(:[], 'actionSourceId'),
  :from_mailbox => thread.try(:[], 'fromMailbox').try(:[], 'name'),
  :state => thread.try(:[], 'state'),
  :body => thread.try(:[], 'body'),
  :to => thread.try(:[], 'to').try(:join, ', '),
  :cc => thread.try(:[], 'cc').try(:join, ', '),
  :bcc => thread.try(:[], 'bcc').try(:join, ', '))

  saved_conversation_thread = ConversationThread.find_by_id(thread.try(:[], 'id'))

  saved_conversation.conversation_threads << saved_conversation_thread

  possible_people = ['assignedTo', 'createdBy', 'customer']
  possible_people.each do |possible_person|
    if thread[possible_person]
      save_conversation_thread_person(saved_conversation_thread, thread[possible_person], possible_person)
    end
  end
end

def save_conversation_thread_person(saved_conversation_thread, person, kind)
  Person.create(:id => person.try(:[], 'id'),
  :first_name => person.try(:[], 'firstName'),
  :last_name => person.try(:[], 'lastName'),
  :email => person.try(:[], 'email'),
  :phone => person.try(:[], 'phone'),
  :person_type => person.try(:[], 'type'))

  saved_person = Person.find_by_id(person.try(:[], 'id'))

  case kind
  when 'assignedTo'
    saved_person.assigned_conversation_threads << saved_conversation_thread
  when 'createdBy'
    saved_person.created_conversation_threads << saved_conversation_thread
  else
    saved_person.customer_conversation_threads << saved_conversation_thread
  end
end

def check_conversation_business_hours(created_at)
  business_hours = (ENV['BUSINESS_HOURS_OPEN'].to_i)..(ENV['BUSINESS_HOURS_CLOSE'].to_i - 1)
  weekdays_off = ENV['WEEKDAYS_OFF'].split(',').map{|s| s.to_i }

  if (business_hours.include? created_at.in_time_zone(ENV['TIME_ZONE']).hour) && (!weekdays_off.include?(created_at.in_time_zone(ENV['TIME_ZONE']).wday)) && (!is_holiday?(created_at.in_time_zone(ENV['TIME_ZONE']).to_date))
    true
  else
    false
  end
end

def get_first_response_thread(saved_conversation)
  if saved_conversation.conversation_threads.count == 0
    return nil
  end

  saved_conversation.conversation_threads.order('created_at ASC').each do |thread|
    if (thread == saved_conversation.conversation_threads.order('created_at ASC').first) || (thread.source.include? 'emailfwd') || (!thread.thread_type.include? 'message')
      next
    end

    if thread.creator.person_type == 'user'
      return thread
    end
  end

  nil
end

def get_first_response_duration(first_thread, first_response_thread)
  if first_response_thread.nil?
    nil
  else
    (first_response_thread.created_at.to_time - first_thread.created_at.to_time).to_i
  end
end

def scan_for_special_case(saved_conversation, first_response_thread)
  if first_response_thread.nil?
    return true
  end

  email_filters = %w(mailer-daemon@googlemail.com no-reply noreply spam)
  subject_filters = ['out of office', 'automatic reply']

  if (!saved_conversation.tags.empty?) && (saved_conversation.tags.any?{|tag| tag.name == 'specialcase'})
    return 1
  end

  email_filters.each do |filter|
    if (saved_conversation.creator.try(:email).nil?) || (saved_conversation.creator.try(:email).try(:downcase).try(:include?, filter))
      return true
    end
  end

  subject_filters.each do |filter|
    if (saved_conversation.subject) && (saved_conversation.subject.try(:downcase).try(:include?, filter))
      return true
    end
  end

  if saved_conversation.status == 'spam'
    return true
  end

  false
end

def save_conversation_metric(saved_conversation)
  saved_conversation_url = "https://secure.helpscout.net/conversation/#{saved_conversation.id}/#{saved_conversation.number}/"
  first_thread = saved_conversation.conversation_threads.order('created_at ASC').first
  first_response_thread = get_first_response_thread(saved_conversation)
  first_response_duration = get_first_response_duration(first_thread, first_response_thread)
  during_business_hours = check_conversation_business_hours(saved_conversation.created_at.in_time_zone(ENV['TIME_ZONE']))
  special_case = scan_for_special_case(saved_conversation, first_response_thread)

  saved_metric = ConversationMetric.create(:id => saved_conversation.id,
  :created_at => saved_conversation.created_at,
  :status => saved_conversation.status,
  :url => saved_conversation_url,
  :started_by => first_thread.creator,
  :first_response_duration => first_response_duration,
  :during_business_hours => during_business_hours,
  :special_case => special_case)
end

def transform_helpscout_conversation(conversation)
  Conversation.create(:id => conversation.try(:[], 'id'),
  :conversation_type => conversation.try(:[], 'type'),
  :is_draft => conversation.try(:[], 'isDraft'),
  :number => conversation.try(:[], 'number'),
  :thread_count => conversation.try(:[], 'threadCount'),
  :status => conversation.try(:[], 'status'),
  :subject => conversation.try(:[], 'subject'),
  :preview => conversation.try(:[], 'preview'),
  :mailbox => conversation.try(:[], 'mailbox').try(:[], 'name'),
  :cc => conversation.try(:[], 'cc').try(:join, ', '),
  :bcc => conversation.try(:[], 'bcc').try(:join, ', '),
  :source => conversation.try(:[], 'source').try(:values).try(:join, ' via '),
  :created_at => conversation.try(:[], 'createdAt'),
  :modified_at => conversation.try(:[], 'modifiedAt'),
  :closed_at => conversation.try(:[], 'closedAt'))

  saved_conversation = Conversation.find_by_id(conversation.try(:[], 'id'))

  if conversation['tags']
    conversation['tags'].each do |tag|
      save_conversation_tag(saved_conversation, tag)
    end
  end

  possible_people = ['owner', 'customer', 'createdBy', 'closedBy']
  possible_people.each do |possible_person|
    if conversation[possible_person]
      save_conversation_person(saved_conversation, conversation[possible_person], possible_person)
    end
  end

  if conversation['threads']
    conversation['threads'].each do |thread|
      save_conversation_thread(saved_conversation, thread)
    end
  end

  save_conversation_metric(saved_conversation)

  puts "Conversation #{conversation['id']} transformed"
end
