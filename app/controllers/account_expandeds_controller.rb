class AccountExpandedsController < BaseController
  before_action -> {
    authenticate_account!
    set_account_expanded
  }

  def edit
    if request.patch? then
      @account_expanded.update account_expanded_params
      session[:success_messages].push "更新が完了しました。"
      redirect_to '/account_expandeds/edit/'
    end
    @description = "アカウント名の変更"
  end

  private
  def account_expanded_params
    params.require(:account_expanded).permit(:name)
  end
end
