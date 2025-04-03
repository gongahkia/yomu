class LeaderboardController < ApplicationController
  def index
    @top_readers = User.order(points: :desc).limit(10)
    @top_completions = User.joins(:book_completions)
                          .select('users.*, COUNT(book_completions.id) as completion_count')
                          .group('users.id')
                          .order('completion_count DESC')
                          .limit(10)
    @top_reviewers = User.joins(:reviews)
                         .select('users.*, COUNT(reviews.id) as review_count')
                         .group('users.id')
                         .order('review_count DESC')
                         .limit(10)
  end
end
