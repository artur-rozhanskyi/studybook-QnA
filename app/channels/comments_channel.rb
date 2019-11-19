class CommentsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'question/comments'
  end
end
