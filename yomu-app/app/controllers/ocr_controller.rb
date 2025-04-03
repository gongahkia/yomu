class OcrController < ApplicationController
  def upload
    @reading_session = ReadingSession.find(params[:reading_session_id])
  end

  def process_image
    image = params[:image]
    image_path = Rails.root.join('tmp', "upload_#{Time.now.to_i}.jpg")
    File.open(image_path, 'wb') do |file|
      file.write(image.read)
    end
    text = RTesseract.new(image_path.to_s).to_s
    File.delete(image_path) if File.exist?(image_path)
    @reading_session = ReadingSession.find(params[:reading_session_id])
    if text.length > 50
      @reading_session.update(verified: true)
      current_user.update(points: current_user.points + @reading_session.pages_read)
      redirect_to dashboard_path, notice: "Reading verified through image! You earned #{@reading_session.pages_read} points."
    else
      redirect_to upload_ocr_path(reading_session_id: @reading_session.id), alert: "Couldn't verify the image. Please try again with a clearer picture."
    end
  end
end
