class UsersController < ApplicationController
  before_action :require_user_logged_in, only: [:index, :show, :new, :create, :followings, :followers, :favorites]  
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    @q = User.ransack(params[:q])
    @users = @q.result.order(id: :DESC).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
    # @microposts = @user.microposts.order('created_at DESC').page(params[:page])
    counts(@user)
    @q = Micropost.ransack(params[:q])
    @microposts = @q.result.where(retweet_id: nil).order(id: :DESC).page(params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = 'ユーザを登録しました。'
      redirect_to @user
    else
      flash.now[:danger] = 'ユーザの登録に失敗しました。'
     render :new
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    
    if @user.update(user_params)
      flash[:success] = 'ユーザー情報は正常に更新されました。'
      redirect_to @user
    else
      flash.now[:danger] = 'ユーザー情報は更新されませんでした。'
      render :edit
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = 'ユーザー情報は正常に削除されました。'
    redirect_to root_url
  end

  def followings
    @user = User.find(params[:id])
    @followings = @user.followings.page(params[:page])
    counts(@user)
  end
  
  def followers
    @user = User.find(params[:id])
    @followers = @user.followers.page(params[:page])
    counts(@user)
  end
  
  def favorites
     @user = User.find(params[:id])
     @microposts = @user.favorite_microposts.page(params[:page])
     counts(@user)
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  
  def correct_user
    @user = User.find_by(id: params[:id])
    unless current_user == @user
      redirect_back(fallback_location: root_path)
    end
  end
  
end