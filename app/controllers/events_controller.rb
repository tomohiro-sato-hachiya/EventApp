class EventsController < BaseController
  before_action -> {
    authenticate_account!
    set_account_expanded
  }, only:[:new, :edit, :destroy,:organizing]
  before_action :set_event, only:[:edit, :destroy]
  before_action :set_place_id_options, only:[:new, :edit]

  def index
    @events = Event.all.order('created_at DESC')
    @description = "イベント情報一覧"
    @entry_status_hash = Hash.new
    if account_signed_in? then
      set_account_expanded
      @events.each do |event|
        if Participant.where("event_id == ? and account_expanded_id == ?", event.id, @account_expanded.id)[0] != nil
          participant = Participant.where("event_id == ? and account_expanded_id == ?", event.id, @account_expanded.id)[0]
          @entry_status_hash[event.id] = judge_entry participant
        end
      end
    end
    set_entry_datetime_hash @events
    set_event_datetime_hash @events
  end

  def show
    @description = "イベント情報詳細"
    @event = Event.find params[:id]
    @entry_disable = false
    @cancelable = false
    @entry_status = nil
    if account_signed_in? then
      set_account_expanded
      if @event.account_expanded_id == @account_expanded.id then
        @entry_disable = true
      end
      if Participant.where("event_id == ? and account_expanded_id == ?", @event.id, @account_expanded.id)[0] != nil then
        @entry_disable = true
        @cancelable = true
        participant = Participant.where("event_id == ? and account_expanded_id == ?", @event.id, @account_expanded.id)[0]
        @entry_status = judge_entry participant
      end
    end
    if @event.entry_start_datetime > DateTime.now || DateTime.now > @event.entry_end_datetime then
      @entry_disable = true
    end
    @entry_datetime = judge_entry_datetime @event
    @event_datetime = judge_event_datetime @event
    set_event_participants
  end

  def new
    @event = Event.new
    if request.post? then
      @event = Event.new event_params
      @event.account_expanded_id = @account_expanded.id
      if @event.save then
        session[:success_messages].push "登録が完了しました。"
        redirect_to '/' + @event.id.to_s
      end
    end
    @description = "イベント新規作成"
    @event.account_expanded_id = @account_expanded.id
    @event.participant_limit = 1
  end

  def edit
    if @event.nil? then
      session[:error_messages].push "指定されたイベント情報は存在しないか更新権限がございません。"
      redirect_to '/'
    end
    if request.patch? then
      @event.update event_params
      session[:success_messages].push "更新が完了しました。"
      redirect_to '/events/edit/' + @event.id.to_s
    end
    @description = "イベント編集"
    set_event_participants
    @started = @event.event_start_datetime <= DateTime.now
  end

  def destroy
    if @event.nil? then
      session[:error_messages].push "指定されたイベント情報は存在しないか削除権限がございません。"
      redirect_to '/'
    end
    @event.destroy
    session[:success_messages].push "削除が完了しました。"
    redirect_to '/'
  end

  def organizing
    @description = "主催イベント情報一覧"
    events = Event.where("account_expanded_id == ?", @account_expanded.id)
    set_entry_datetime_hash events
    set_event_datetime_hash events
    set_datetime_events events
  end

  private
  def event_params
    params.require(:event).permit(
      :name,
      :detail,
      :place_id,
      :address,
      :online,
      :event_start_datetime,
      :event_end_datetime,
      :entry_start_datetime,
      :entry_end_datetime,
      :participant_limit
    )
  end

  def set_sub_title
    @subtitle = "イベント"
  end

  def set_place_id_options
    @id_options = Array.new
    index = 0
    PLACE_ID_ARRAY.each do |item|
      @id_options.push [item, index]
      index += 1
    end
  end

  def set_event
    @event = Event.where("id == ? and account_expanded_id == ?", params[:id], @account_expanded.id)[0]
  end

  def set_event_participants
    @participate_able_participants = Array.new
    @participate_disable_participants = Array.new
    @event.participants.each do |participant|
      entry = judge_entry participant
      if entry == JUDGE_ENTRY_ABLE then
        @participate_able_participants.push participant
      end
      if entry == JUDGE_ENTRY_DISABLE then
        @participate_disable_participants.push participant
      end
    end
  end
end
