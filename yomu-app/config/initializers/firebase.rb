require 'firebase'

# FUA to add the firebase URL and SECRET to a local .env file in the actual script

FIREBASE = Firebase::Client.new(
  ENV['FIREBASE_URL'],
  ENV['FIREBASE_SECRET']
)
