require 'net/http'
require 'json'

class TriviaController < ApplicationController
  before_action :authenticate_user!

  def index
    @reading_session = ReadingSession.find(params[:reading_session_id])
    @book = @reading_session.book
    @question = @book.trivia_questions.order("RANDOM()").first
    if @question.nil?
      @question = generate_question(@book, @reading_session.pages_read)
    end
  end

  def verify
    @reading_session = ReadingSession.find(params[:reading_session_id])
    @question = TriviaQuestion.find(params[:question_id])
    if params[:answer].downcase.include?(@question.answer.downcase)
      @reading_session.update(verified: true)
      current_user.update(points: current_user.points + @reading_session.pages_read)
      if @reading_session.pages_read + current_user.reading_sessions.where(book_id: @reading_session.book_id).sum(:pages_read) >= @reading_session.book.total_pages
        BookCompletion.create(user: current_user, book: @reading_session.book, completed_at: Time.now)
        redirect_to new_review_path(book_id: @reading_session.book_id), notice: "Congratulations! You've completed this book. Leave a review for bonus points!"
      else
        redirect_to dashboard_path, notice: "Reading verified! You earned #{@reading_session.pages_read} points."
      end
    else
      @reading_session.destroy
      redirect_to new_reading_session_path, alert: "Verification failed. Please try again."
    end
  end

  private

  def generate_question(book, current_page)
    uri = URI("https://api.gemeeni2.com/generate_question")
    params = { book_title: book.title, page: current_page }
    response = Net::HTTP.post(uri, params.to_json, { "Content-Type" => "application/json" })

    if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        question_text = data["question"] || "No question generated."
        answer_text = data["answer"] || "Unknown"
    else
        question_text = "Error generating question."
        answer_text = "Unknown"
    end

    TriviaQuestion.create(
        book: book,
        question: question_text,
        answer: answer_text,
        difficulty: 1
    )
  end

end
