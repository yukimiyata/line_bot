class LinebotController < ApplicationController
  require 'line/bot'
  require 'open-uri'

  protect_from_forgery :except => [:callback]

  def callback
    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV['SECRET_KEY']
      config.channel_token = ENV['TOKEN_KEY']
    }
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.message['text'] == 'こんにちは'
            client.reply_message(
                event['replyToken'],
                {
                    type: 'text',
                    text: 'こんにちは'
                }
            )
          elsif event.message['text'] == 'こんばんは'
            client.reply_message(
                event['replyToken'],
                {
                    type: 'text',
                    text: 'こんばんは'
                }
            )
          elsif event.message['text'] == 'はやし'
            client.reply_message(
                event['replyToken'],
                {
                    type: 'text',
                    text: '酒カスやな'
                }
            )
          elsif event.message['text'] == 'らびっしゅ'
            client.reply_message(
                event['replyToken'],
                {
                    type: 'text',
                    text: 'クズやな'
                }
            )
          elsif event.message['text'] == 'せお'
            client.reply_message(
                event['replyToken'],
                {
                    type: 'text',
                    text: 'パチンカスやな'
                }
            )
          elsif event.message['text'] == 'みやた'
            client.reply_message(
                event['replyToken'],
                {
                    type: 'text',
                    text: '紳士です。'
                }
            )
          elsif event.message['text'] == '天気'
            response = open('http://weather.livedoor.com/forecast/webservice/json/v1?city=130010')
            json = JSON.parse(response.read)
            client.reply_message(
                event['replyToken'],
                {
                    type: 'text',
                    text: "#{json['forecasts'][0]['dateLabel']}の天気は#{json['forecasts'][0]['telop']}です"
                }
            )
          else
            client.reply_message(
                event['replyToken'],
                {
                    type: 'text',
                    text: 'すいません。よくわかりません。'
                }
            )
          end
        end
      end
    }
    head :ok
  end
end