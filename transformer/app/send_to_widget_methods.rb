require 'active_record'
require 'date'
require 'week_of_month'
require 'pry'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

def send_response_time(current_value, pp_value, ly_value, time_period)
  HTTParty.post("http://#{request.host}:3030/widgets/response_time_#{time_period}", :body => {current: current_value, plast: pp_value, ylast: ly_value}.to_json)
end

def send_response_time_slowest(current_value, pp_value, ly_value, time_period)
  HTTParty.post("http://#{request.host}:3030/widgets/slowest_response_time_#{time_period}", :body => {current: current_value, plast: pp_value, ylast: ly_value}.to_json)
end

def send_percent_on_goal(current_value, pp_value, ly_value, time_period)
  HTTParty.post("http://#{request.host}:3030/widgets/percent_on_goal_#{time_period}", :body => {current: current_value, plast: pp_value, ylast: ly_value}.to_json)
end

def send_total_cases(current_value, time_period)
  HTTParty.post("http://#{request.host}:3030/widgets/total_cases_#{time_period}", :body => {current: current_value}.to_json)
end

def send_cases_outside_hours(current_value, pp_value, ly_value, time_period)
  HTTParty.post("http://#{request.host}:3030/widgets/cases_outside_hours_#{time_period}", :body => {current: current_value, plast: pp_value, ylast: ly_value}.to_json)
end

def send_most_active_customer(first_name, last_name, email, count, time_period)
  HTTParty.post("http://#{request.host}:3030/widgets/most_active_#{time_period}", :body => {name: "#{first_name} #{last_name}", email: email, count: "#{count}"}.to_json)
end

def get_conversation_metrics_by_metric_range(metric_range)
  case metric_range
  when "previous_business_day"
    ConversationMetric.where(:created_at => previous_business_day(Date.today).beginning_of_day..previous_business_day(Date.today).end_of_day)
  when "previous_business_day_prior_period"
    pp_previous_business_day = previous_business_day(previous_business_day(Date.today))
    ConversationMetric.where(:created_at => pp_previous_business_day.beginning_of_day..pp_previous_business_day.end_of_day)
  when "previous_business_day_last_year"
    ly_previous_business_day = previous_business_day(previous_business_day(Date.today - 1.years))
    ConversationMetric.where(:created_at => ly_previous_business_day.beginning_of_day..ly_previous_business_day.end_of_day)
  when "previous_completed_week"
    last_week_start = (Date.today - 1.weeks).beginning_of_week.beginning_of_day
    last_week_end = (Date.today - 1.weeks).end_of_week.end_of_day
    ConversationMetric.where(:created_at => last_week_start..last_week_end)
  when "previous_completed_week_prior_period"
    pp_week_start = (Date.today - 2.weeks).beginning_of_week.beginning_of_day
    pp_week_end = (Date.today - 2.weeks).end_of_week.end_of_day
    ConversationMetric.where(:created_at => pp_week_start..pp_week_end)
  when "previous_completed_week_last_year"
    ly_week_start = (Date.today - 53.weeks).beginning_of_week.beginning_of_day
    ly_week_end = (Date.today - 53.weeks).end_of_week.end_of_day
    ConversationMetric.where(:created_at => ly_week_start..ly_week_start)
  when "previous_completed_month"
    last_month_start = (Date.today - 1.months).beginning_of_month.beginning_of_day
    last_month_end = (Date.today - 1.months).end_of_month.end_of_day
    ConversationMetric.where(:created_at => last_month_start..last_month_end)
  when "previous_completed_month_prior_period"
    pp_month_start = (Date.today - 2.months).beginning_of_month.beginning_of_day
    pp_month_end = (Date.today - 2.months).end_of_month.end_of_day
    ConversationMetric.where(:created_at => pp_month_start..pp_month_end)
  when "previous_completed_month_last_year"
    ly_month_start = (Date.today - 13.months).beginning_of_month.beginning_of_day
    ly_month_end = (Date.today - 13.months).end_of_month.end_of_day
    ConversationMetric.where(:created_at => ly_month_start..ly_month_start)
  when "previous_completed_quarter"
    last_quarter_dates = quarter_dates(1)
    ConversationMetric.where(:created_at => last_quarter_dates.first.beginning_of_day..last_quarter_dates.last.end_of_day)
  when "previous_completed_quarter_prior_period"
    pp_last_quarter_dates = quarter_dates(2)
    ConversationMetric.where(:created_at => pp_last_quarter_dates.first.beginning_of_day..pp_last_quarter_dates.last.end_of_day)
  when "previous_completed_quarter_last_year"
    ly_last_quarter_dates = quarter_dates(5)
    ConversationMetric.where(:created_at => ly_last_quarter_dates.first.beginning_of_day..ly_last_quarter_dates.last.end_of_day)
  else
    "Not a valid range"
  end
end

def send_helpscout_data_to_widgets
  metrics_hashes = [
    {
      :current => get_conversation_metrics_by_metric_range("previous_business_day"),
      :plast => get_conversation_metrics_by_metric_range("previous_business_day_prior_period"),
      :ylast => get_conversation_metrics_by_metric_range("previous_business_day_last_year"),
      :time_period => 'day'
    },
    {
      :current => get_conversation_metrics_by_metric_range("previous_completed_week"),
      :plast => get_conversation_metrics_by_metric_range("previous_completed_week_prior_period"),
      :ylast => get_conversation_metrics_by_metric_range("previous_completed_week_last_year"),
      :time_period => 'week'
    },
    {
      :current => get_conversation_metrics_by_metric_range("previous_completed_month"),
      :plast => get_conversation_metrics_by_metric_range("previous_completed_month_prior_period"),
      :ylast => get_conversation_metrics_by_metric_range("previous_completed_month_last_year"),
      :time_period => 'month'
    },
    {
      :current => get_conversation_metrics_by_metric_range("previous_completed_quarter"),
      :plast => get_conversation_metrics_by_metric_range("previous_completed_quarter_prior_period"),
      :ylast => get_conversation_metrics_by_metric_range("previous_completed_quarter_last_year"),
      :time_period => 'quarter'
    }
  ]

  metrics_hashes.each do |metrics_hash|
    current_rt = metrics_hash[:current].where(:during_business_hours => true).where(:special_case => false).where.not('first_response_duration' => nil).order('first_response_duration DESC')
    plast_rt = metrics_hash[:plast].where(:during_business_hours => true).where(:special_case => false).where.not('first_response_duration' => nil)
    ylast_rt = metrics_hash[:ylast].where(:during_business_hours => true).where(:special_case => false).where.not('first_response_duration' => nil)

    send_response_time(current_rt.average(:first_response_duration).to_i, plast_rt.average(:first_response_duration).to_i, ylast_rt.average(:first_response_duration).to_i, metrics_hash[:time_period])
    send_response_time_slowest(current_rt.maximum(:first_response_duration).to_i, plast_rt.maximum(:first_response_duration).to_i, ylast_rt.maximum(:first_response_duration).to_i, metrics_hash[:time_period])
    send_percent_on_goal(metrics_hash[:current].where(:during_business_hours => true).where("first_response_duration <= #{ENV['HELPSCOUT_GOAL_BUSINESS_HOURS']}").count, metrics_hash[:plast].where(:during_business_hours => true).where("first_response_duration <= #{ENV['HELPSCOUT_GOAL_BUSINESS_HOURS']}").count, metrics_hash[:ylast].where(:during_business_hours => true).where('first_response_duration <= 900').count, metrics_hash[:time_period])
    send_total_cases(metrics_hash[:current].count, metrics_hash[:time_period])
    send_cases_outside_hours(metrics_hash[:current].where(:during_business_hours => false).count, metrics_hash[:plast].where(:during_business_hours => false).count, metrics_hash[:ylast].where(:during_business_hours => false).count, metrics_hash[:time_period])

    most_active_customer_hash = get_most_active_customer(metrics_hash[:current])
    most_active_customer = most_active_customer_hash[:most_active_customer]
    most_active_customer_thread_count = most_active_customer_hash[:thread_count]
    send_most_active_customer(most_active_customer.try(:[],:'first_name'), most_active_customer.try(:[],:'last_name'), most_active_customer.try(:[],:'email'), most_active_customer_thread_count, metrics_hash[:time_period])
  end

  HTTParty.post("http://#{request.host}:3030/widgets/active_cases", :body => {current: Conversation.where(:status => 'active').count}.to_json)
end

def empty_widgets
  widgets = %w(response_time_day response_time_week response_time_month response_time_quarter
  slowest_response_time_day slowest_response_time_week slowest_response_time_month slowest_response_time_quarter
  percent_on_goal_day percent_on_goal_week percent_on_goal_month percent_on_goal_quarter
  total_cases_day total_cases_week total_cases_month total_cases_quarter
  cases_outside_hours_day cases_outside_hours_week cases_outside_hours_month cases_outside_hours_quarter
  most_active_day most_active_week most_active_month most_active_quarter active_cases)

  widgets.each do |widget|
    if widget.include?('most_active')
      HTTParty.post("http://#{request.host}:3030/widgets/#{widget}",:body => {name: nil, email: nil, number: nil}.to_json)
    elsif widget.include?('total') || widget.include?('active_cases')
      HTTParty.post("http://#{request.host}:3030/widgets/#{widget}",:body => {current: nil}.to_json)
    else
      HTTParty.post("http://#{request.host}:3030/widgets/#{widget}",:body => {current: nil, plast: nil, ylast: nil}.to_json)
    end
  end
end


##################
# Utility Methods
##################

def next_business_day(date)
  skip_weekends(date, 1)
end

def previous_business_day(date)
  skip_weekends(date, -1)
end

def skip_weekends(date, inc)
  date += inc
  while (date.wday % 7 == 0) or (date.wday % 7 == 6) do
    date += inc
  end
  date
end

def quarter_dates(offset)
  date = Date.today << (offset * 3)
  [date.beginning_of_quarter, date.end_of_quarter]
end

def get_most_active_customer(conversation_metrics)
  ids = []

  conversation_metrics.find_each do |conversation_metric|
    conversation_threads = Conversation.find_by_id(conversation_metric.id).conversation_threads

    unless conversation_threads.empty?
      conversation_threads.each do |thread|
        unless  (thread.creator.nil?) || (thread.creator.person_type == 'user') || (thread.creator.email.try(:include?, '@opensesame.com'))
          ids << thread.creator.id
        end
      end
    end
  end

  # http://stackoverflow.com/questions/412169/ruby-how-to-find-item-in-array-which-has-the-most-occurrences
  freq = ids.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
  most_active_customer_id = ids.max_by { |v| freq[v] }

  most_active_customer = Person.find_by_id(most_active_customer_id)
  thread_count = ids.delete_if {|id| id != most_active_customer_id}.count

  {:most_active_customer => most_active_customer, :thread_count => thread_count}
end

def is_on_goal(conversation_metric)
  is_on_goal = false

  created_at_local = conversation_metric.created_at.in_time_zone(ENV['TIME_ZONE'])
  weekdays_off = ENV['WEEKDAYS_OFF'].split(',').map{|s| s.to_i }
  helpscout_goal_business_hours = ENV['HELPSCOUT_GOAL_BUSINESS_HOURS'].to_i
  helpscout_goal_off_hours = ENV['HELPSCOUT_GOAL_OFF_HOURS'].to_i

  if (weekdays_off.include?(created_at_local.wday) || is_holiday?(created_at_local.strftime('%Y-%m-%d'))) && conversation_metric.first_response_duration.to_i <= helpscout_goal_off_hours
    is_on_goal = true
  elsif !conversation_metric.during_business_hours && conversation_metric.first_response_duration.to_i <= helpscout_goal_off_hours
    is_on_goal = true
  elsif conversation_metric.first_response_duration.to_i <= helpscout_goal_business_hours
    is_on_goal = true
  end

  is_on_goal
end

def is_holiday?(date)
  if date.class == String
    date = date.to_date
  end

  holidays = []
  chosen_holidays = ENV['HOLIDAYS'].split(',')

  us_national_holidays = {
    'newyearseve' => "#{date.year}-12-31",
    'newyearsday' => "#{date.year}-01-01",
    'martinlutherkingsbirthday' => "#{date.year}-01-#{Date.new(date.year,1,1).all_mondays_in_month[2]}",
    'georgewashingtonsbirthday' => "#{date.year}-02-#{Date.new(date.year,2,1).all_mondays_in_month[2]}",
    'presidentsday' => "#{date.year}-02-#{Date.new(date.year,2,1).all_mondays_in_month[2]}",
    'memorialday' => "#{date.year}-5-#{Date.new(date.year,5,1).all_mondays_in_month.last}",
    'fourthofjuly' => "#{date.year}-07-04",
    'laborday' => "#{date.year}-9-#{Date.new(date.year,9,1).all_mondays_in_month.first}",
    'columbusday' => "#{date.year}-10-#{Date.new(date.year,10,1).all_mondays_in_month[1]}",
    'veteransday' => "#{date.year}-11-11",
    'thanksgiving' => "#{date.year}-11-#{Date.new(date.year,11,1).all_thursdays_in_month[3]}",
    'dayafterthanksgiving' => "#{date.year}-11-#{Date.new(date.year,11,1).all_fridays_in_month[3]}",
    'christmaseve' => "#{date.year}-12-24",
    'christmasday' => "#{date.year}-12-25"
  }

  chosen_holidays.each do |chosen_holiday|
    formatted_chosen_holiday = chosen_holiday.downcase.delete(' ').delete("'")
    if us_national_holidays.keys.include? formatted_chosen_holiday
      holidays << us_national_holidays[formatted_chosen_holiday]
    end
  end

  if holidays.include? date.to_s
    true
  else
    false
  end
end

def get_num_on_goal(conversation_metrics)
  num_on_goal = 0

  conversation_metrics.each do |conversation_metric|
    if is_on_goal(conversation_metric)
      num_on_goal += 1
    end
  end

  num_on_goal
end

def get_num_off_goal(conversation_metrics)
  if conversation_metrics.empty?
    return nil
  else
    num_on_goal = get_num_on_goal(conversation_metrics)
  end

  conversation_metrics.length - num_on_goal
end

def get_percent_on_goal(conversation_metrics)
  if conversation_metrics.empty?
    return nil
  else
    num_on_goal = get_num_on_goal(conversation_metrics)
  end

  (num_on_goal.to_f / conversation_metrics.length.to_f * 100).round
end
