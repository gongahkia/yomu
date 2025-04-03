class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :reading_sessions
  has_many :book_completions
  has_many :reviews
  has_many :perks

  def total_pages_read
    reading_sessions.sum(:pages_read)
  end

  def books_completed
    book_completions.count
  end
end
