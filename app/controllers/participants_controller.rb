class ParticipantsController < BaseController
  before_action -> {
    authenticate_account!
    set_account_expanded
  }, except: :entrying

  def new
    redirect_url = "/"
    @event = Event.find params[:id]
    if @event.nil? then
      session[:error_messages].push "指定されたイベント情報は存在しません。"
      redirect_to redirect_url and return
    end
    redirect_url = "/events/" + @event.id.to_s
    if @event.account_expanded_id == @account_expanded.id then
      session[:error_messages].push "主催者はエントリーできません。"
      redirect_to redirect_url and return
    end
    if Participant.where("event_id == ? and account_expanded_id == ?", @event.id, @account_expanded.id)[0] != nil then
      session[:error_messages].push "すでにエントリーしています。"
      redirect_to redirect_url and return
    end
    if @event.entry_start_datetime > DateTime.now || DateTime.now > @event.entry_end_datetime then
      session[:error_messages].push "エントリー受付時間外です。"
      redirect_to redirect_url and return
    end
    @participant = Participant.new
    @participant.event_id = @event.id
    @participant.account_expanded_id = @account_expanded.id
    @participant.entry_status = ENTRY_STATUS_ARRAY.index(ENTRY_STATUS_NORMAL)
    @participant.participation_status = PARTICIPATION_STATUS_ARRAY.index(PARTICIPATION_STATUS_NORMAL)
    if @participant.save then
      session[:success_messages].push "エントリーが完了しました。"
    else
      session[:error_messages].push "エラーによりエントリーが失敗しました。"
    end
    redirect_to redirect_url and return

  end

  def entry
    set_participant(params[:id])
    if @participant.event.event_start_datetime <= DateTime.now then
      session[:error_messages].push "イベント開始後にはエントリーステータスの変更ができません。"
      redirect_to "/" and return
    end
    if @participant.entry_status == ENTRY_STATUS_ARRAY.index(ENTRY_STATUS_REJECTED) then
      session[:error_messages].push "エントリーを拒否した後にエントリーステータスを再更新することはできません。"
      redirect_to "/" and return
    end
    if request.patch? then
      invited = ENTRY_STATUS_ARRAY.index(ENTRY_STATUS_INVITED)
      if params[:participant][:entry_status].to_i == invited then
        invited_participants = Participant.where("event_id == ? and entry_status == ?", @participant.event.id, invited)
        if invited_participants.size >= @participant.event.participant_limit then
          session[:error_messages].push "招待者数が参加人数上限を超えることはできません。"
          redirect_to "/" and return
        end
      end
      @participant.update entry_params
      redirect_to "/events/edit/" + @participant.event.id.to_s
    end
    @description = "エントリーステータスの編集"
    set_entry_status_options
  end

  def participation
    set_participant(params[:id])
    if @participant.event.event_start_datetime >= DateTime.now then
      session[:error_messages].push "イベント開始前には参加ステータスの変更ができません。"
      redirect_to "/" and return
    end
    if request.patch? then
      @participant.update entry_params
      redirect_to "/events/edit/" + @participant.event.id.to_s
    end
    @description = "参加/不参加ステータスの編集"
    set_participation_status_options
  end

  def destroy
    @participant = Participant.where("event_id == ? and account_expanded_id == ?", params[:id], @account_expanded.id)[0]
    if @participant.nil? then
      session[:error_messages].push "エントリー情報が存在しません。"
      redirect_to "/" and return
    end
    event_id = @participant.event.id
    @participant.destroy
    session[:success_messages].push "エントリーキャンセルが完了しました。"
    redirect_to "/events/" + event_id.to_s and return
  end

  def entrying
    @subtitle = "ホーム"
    @description = "エントリー中のイベント一覧"
    events = Array.new
    @entry_status_hash = Hash.new
    if account_signed_in? then
      set_account_expanded
      @account_expanded.participants.each do |participant|
        events.push participant.event
        @entry_status_hash[participant.event.id] = judge_entry participant
      end
    end
    set_entry_datetime_hash events
    set_event_datetime_hash events
    set_datetime_events events
  end

  private
  def set_sub_title
    @subtitle = "参加者"
  end

  def entry_params
    params.require(:participant).permit(:entry_status)
  end

  def participation_params
    params.require(:participant).permit(:participation_status)
  end

  def set_participant id
    error_message = "参加者情報が取得できませんでした。"
    begin
      @participant = Participant.find id
    rescue ActiveRecord::RecordNotFound => e
      session[:error_messages].push error_message
      redirect_to "/" and return
    end
    if @participant.nil? then
      session[:error_messages].push error_message
      redirect_to "/" and return
    end
    if @participant.event.account_expanded_id != @account_expanded.id then
      session[:error_messages].push error_message
      redirect_to "/" and return
    end
  end

  def set_entry_status_options
    @entry_status_options = Array.new
    index = 0
    ENTRY_STATUS_ARRAY.each do |item|
      @entry_status_options.push [item, index]
      index += 1
    end
  end

  def set_participation_status_options
    @participation_status_options = Array.new
    index = 0
    PARTICIPATION_STATUS_ARRAY.each do |item|
      @participation_status_options.push [item, index]
      index += 1
    end
  end
end
