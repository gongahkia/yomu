class ProfileController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def show
    @user = params[:id] ? User.find(params[:id]) : current_user
    @reading_sessions = @user.reading_sessions.includes(:book).order(date: :desc)
    @completed_books = @user.book_completions.includes(:book).order(completed_at: :desc)
    @reviews = @user.reviews.includes(:book).order(created_at: :desc)
    @perks = @user.perks

    respond_to do |format|
      format.html
      format.json { render json: @user.as_json(include: [:completed_books, :perks]) }
    end
  end

  def update
    if current_user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully!"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :profile_picture)
  end
end
