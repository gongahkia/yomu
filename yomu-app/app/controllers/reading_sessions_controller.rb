class ReadingSessionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @reading_session = ReadingSession.new
    @books = Book.all
  end

  def create
    @reading_session = current_user.reading_sessions.new(reading_session_params)
    @reading_session.date = Date.today
    @reading_session.verified = false

    if @reading_session.save
      redirect_to trivia_path(reading_session_id: @reading_session.id), notice: "Let's verify your reading with a quick question!"
    else
      render :new
    end
  end

  private

  def reading_session_params
    params.require(:reading_session).permit(:book_id, :pages_read)
  end
end
