require 'date'

class BaseController < ApplicationController
  layout 'event'

  before_action -> {
    set_sub_title
    set_error_message
    set_success_message
  }
  private
  def set_sub_title
    @subtitle = ""
  end

  def set_error_message
    if session[:error_messages].nil? then
      session[:error_messages] = Array.new
    end
    @error_messages = session[:error_messages]
    session[:error_messages] = Array.new
  end
  
  def set_success_message
    if session[:success_messages].nil? then
      session[:success_messages] = Array.new
    end
    @success_messages = session[:success_messages]
    session[:success_messages] = Array.new
  end

  def set_account_expanded
    account_expandeds = AccountExpanded.where("account_id == ?", current_account.id)
    if account_expandeds[0] == nil then
      account_expanded = AccountExpanded.new
      account_expanded.account_id = current_account.id
      account_expanded.name = "<<no name>>"
      account_expanded.save
      account_expandeds = AccountExpanded.where "account_id == ?", current_account.id
    end
    @account_expanded = account_expandeds[0]
  end

  def judge_entry participant
    result = JUDGE_ENTRY_DISABLE
    invited = ENTRY_STATUS_ARRAY.index(ENTRY_STATUS_INVITED)
    if participant.entry_status == invited then
      result = JUDGE_ENTRY_ABLE
    end
    normal = ENTRY_STATUS_ARRAY.index(ENTRY_STATUS_NORMAL)
    if participant.entry_status == normal then
      invited_participants = Participant.where("event_id == ? and entry_status == ?", participant.event.id, invited)
      remain = participant.event.participant_limit - invited_participants.size
      if remain > 0 then
        normal_participants = Participant.where("event_id == ? and entry_status == ?", participant.event.id, normal).order(:created_at)
        for index in 0..(remain - 1) do
          if participant.id == normal_participants[index].id then
            result = JUDGE_ENTRY_ABLE
            break
          end
        end
      end
    end
    if participant.entry_status == ENTRY_STATUS_ARRAY.index(ENTRY_STATUS_REJECTED) then
      result = JUDGE_ENTRY_REJECTED
    end
    return result
  end

  def judge_entry_datetime event
    return "エントリー受付" + judge_datetime(event.entry_start_datetime, event.entry_end_datetime)
  end

  def judge_event_datetime event
    return "イベント開催" + judge_datetime(event.event_start_datetime, event.event_end_datetime)
  end

  def judge_datetime(start_datetime, end_datetime)
    if start_datetime > DateTime.now then
      return JUDGE_DATE_TIME_BEFORE
    end
    if end_datetime < DateTime.now then
      return JUDGE_DATE_TIME_AFTER
    end
    return JUDGE_DATE_TIME_IN_PROGRESS
  end

  def set_entry_datetime_hash events
    @entry_datetime_hash = Hash.new
    events.each do |event|
      @entry_datetime_hash[event.id] = judge_entry_datetime event
    end
  end

  def set_event_datetime_hash events
    @event_datetime_hash = Hash.new
    events.each do |event|
      @event_datetime_hash[event.id] = judge_event_datetime event
    end
  end

  def set_datetime_events events
    @in_progress_events = Array.new
    @before_events = Array.new
    @after_events = Array.new
    events.each do |event|
      event_datetime = judge_event_datetime event
      if event_datetime.end_with? JUDGE_DATE_TIME_IN_PROGRESS then
        @in_progress_events.push event
      end
      if event_datetime.end_with? JUDGE_DATE_TIME_BEFORE then
        @before_events.push event
      end
      if event_datetime.end_with? JUDGE_DATE_TIME_AFTER then
        @after_events.push event
      end
    end
  end
end