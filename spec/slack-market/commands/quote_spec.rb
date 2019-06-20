require 'spec_helper'

describe SlackMarket::Commands::Quote do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:message_command) { SlackRubyBot::Hooks::Message.new }
  context 'quote' do
    it 'requires a subscription', vcr: { cassette_name: 'iex/msft' } do
      expect(message: 'MSFT').to respond_with_slack_message([
        'Not showing quotes for Microsoft Corp. (MSFT).',
        team.subscribe_text
      ].join(' '))
    end
    it 'requires a subscription for MSFT and AABA and INVALID', vcr: { cassette_name: 'iex/msft_yahoo_invalid' } do
      expect(message: 'MSFT and AABA or INVALID').to respond_with_slack_message([
        'Not showing quotes for Microsoft Corp. (MSFT) or Altaba, Inc. (AABA).',
        team.subscribe_text
      ].join(' '))
    end
    context 'subscribed team' do
      let(:team) { Fabricate(:team, subscribed: true) }
      it 'returns a quote for MSFT', vcr: { cassette_name: 'iex/msft', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Microsoft Corp. (MSFT): $135.69',
              title_link: 'http://finance.google.com/q=MSFT',
              title: 'Microsoft Corp. (MSFT)',
              text: '$135.69 (+0.39%)',
              color: '#00FF00',
              callback_id: 'Microsoft Corp.',
              actions: [
                {
                  name: '1D',
                  text: '1d',
                  type: 'button',
                  value: 'MSFT- 1d'
                },
                {
                  name: '1M',
                  text: '1m',
                  type: 'button',
                  value: 'MSFT- 1m'
                },
                {
                  name: '1Y',
                  text: '1y',
                  type: 'button',
                  value: 'MSFT- 1y'
                }
              ],
              image_url: '/api/charts/MSFT.png'
            }
          ]
        ).twice
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'MSFT'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's MSFT?"))
      end
      it 'does not repeat stocks', vcr: { cassette_name: 'iex/msft', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).once
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'MSFT MSFT'))
      end
      it 'returns a quote for $MSFT', vcr: { cassette_name: 'iex/msft', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Microsoft Corp. (MSFT): $135.69',
              title_link: 'http://finance.google.com/q=MSFT',
              title: 'Microsoft Corp. (MSFT)',
              text: '$135.69 (+0.39%)',
              color: '#00FF00',
              callback_id: 'Microsoft Corp.',
              actions: [
                {
                  name: '1D',
                  text: '1d',
                  type: 'button',
                  value: 'MSFT- 1d'
                },
                {
                  name: '1M',
                  text: '1m',
                  type: 'button',
                  value: 'MSFT- 1m'
                },
                {
                  name: '1Y',
                  text: '1y',
                  type: 'button',
                  value: 'MSFT- 1y'
                }
              ],
              image_url: '/api/charts/MSFT.png'
            }
          ]
        ).exactly(3).times
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$MSFT?'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $MSFT?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $msft?"))
      end
      it 'returns a quote for MSFT and AABA', vcr: { cassette_name: 'iex/msft_yahoo_invalid' } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Microsoft Corp. (MSFT): $135.69',
              title_link: 'http://finance.google.com/q=MSFT',
              title: 'Microsoft Corp. (MSFT)',
              text: '$135.69 (+0.39%)',
              color: '#00FF00',
              callback_id: 'Microsoft Corp.',
              actions: [
                {
                  name: '1D',
                  text: '1d',
                  type: 'button',
                  value: 'MSFT- 1d'
                },
                {
                  name: '1M',
                  text: '1m',
                  type: 'button',
                  value: 'MSFT- 1m'
                },
                {
                  name: '1Y',
                  text: '1y',
                  type: 'button',
                  value: 'MSFT- 1y'
                }
              ],
              image_url: '/api/charts/MSFT.png'
            },
            {
              fallback: 'Altaba, Inc. (AABA): $68.48',
              title_link: 'http://finance.google.com/q=AABA',
              title: 'Altaba, Inc. (AABA)',
              text: '$68.48 (-0.34%)',
              color: '#FF0000',
              callback_id: 'Altaba, Inc.',
              actions: [
                {
                  name: '1D',
                  text: '1d',
                  type: 'button',
                  value: 'AABA- 1d'
                },
                {
                  name: '1M',
                  text: '1m',
                  type: 'button',
                  value: 'AABA- 1m'
                },
                {
                  name: '1Y',
                  text: '1y',
                  type: 'button',
                  value: 'AABA- 1y'
                }
              ],
              image_url: '/api/charts/AABA.png'
            }
          ]
        )
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's MSFT or AABA and INVALID?"))
      end
      it 'does not trigger with a channel ID' do
        expect(client.web_client).to_not receive(:chat_postMessage)
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'I created <#C04KB5X4D>!'))
      end
      it 'does not trigger with a I have' do
        expect(client.web_client).to_not receive(:chat_postMessage)
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'I have'))
      end
      it 'does not trigger with a have I done' do
        expect(client.web_client).to_not receive(:chat_postMessage)
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'have I done'))
      end
      it 'returns a quote for a single-character $stock', vcr: { cassette_name: 'iex/f', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Ford Motor Co. (F): $10.04',
              title_link: 'http://finance.google.com/q=F',
              title: 'Ford Motor Co. (F)',
              text: '$10.04 (-0.59%)',
              color: '#FF0000',
              callback_id: 'Ford Motor Co.',
              actions: [
                {
                  name: '1D',
                  text: '1d',
                  type: 'button',
                  value: 'F- 1d'
                },
                {
                  name: '1M',
                  text: '1m',
                  type: 'button',
                  value: 'F- 1m'
                },
                {
                  name: '1Y',
                  text: '1y',
                  type: 'button',
                  value: 'F- 1y'
                }
              ],
              image_url: '/api/charts/F.png'
            }
          ]
        ).exactly(4).times
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $F?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $f?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$f'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$F'))
      end
      it 'returns a quote for a single-character stock$', vcr: { cassette_name: 'iex/f' } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Ford Motor Co. (F): $10.04',
              title_link: 'http://finance.google.com/q=F',
              title: 'Ford Motor Co. (F)',
              text: '$10.04 (-0.59%)',
              color: '#FF0000',
              callback_id: 'Ford Motor Co.',
              actions: [
                {
                  name: '1D',
                  text: '1d',
                  type: 'button',
                  value: 'F- 1d'
                },
                {
                  name: '1M',
                  text: '1m',
                  type: 'button',
                  value: 'F- 1m'
                },
                {
                  name: '1Y',
                  text: '1y',
                  type: 'button',
                  value: 'F- 1y'
                }
              ],
              image_url: '/api/charts/F.png'
            }
          ]
        )
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's F$?"))
      end
      context 'with dollars on' do
        before do
          team.update_attributes!(dollars: true)
        end
        it 'does not trigger with MSFT' do
          expect(client.web_client).to_not receive(:chat_postMessage)
          message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'How is MSFT?'))
        end
        it 'returns a quote for $MSFT', vcr: { cassette_name: 'iex/msft' } do
          expect(client.web_client).to receive(:chat_postMessage).with(
            channel: 'channel',
            as_user: true,
            attachments: [
              {
                fallback: 'Microsoft Corp. (MSFT): $135.69',
                title_link: 'http://finance.google.com/q=MSFT',
                title: 'Microsoft Corp. (MSFT)',
                text: '$135.69 (+0.39%)',
                color: '#00FF00',
                callback_id: 'Microsoft Corp.',
                actions: [
                  {
                    name: '1D',
                    text: '1d',
                    type: 'button',
                    value: 'MSFT- 1d'
                  },
                  {
                    name: '1M',
                    text: '1m',
                    type: 'button',
                    value: 'MSFT- 1m'
                  },
                  {
                    name: '1Y',
                    text: '1y',
                    type: 'button',
                    value: 'MSFT- 1y'
                  }
                ],
                image_url: '/api/charts/MSFT.png'
              }
            ]
          )
          message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $MSFT?"))
        end
      end
      context 'with charts off' do
        before do
          team.update_attributes!(charts: false)
        end
        it 'returns a quote for MSFT without a chart', vcr: { cassette_name: 'iex/msft' } do
          expect(client.web_client).to receive(:chat_postMessage).with(
            channel: 'channel',
            as_user: true,
            attachments: [
              {
                fallback: 'Microsoft Corp. (MSFT): $135.69',
                title_link: 'http://finance.google.com/q=MSFT',
                title: 'Microsoft Corp. (MSFT)',
                text: '$135.69 (+0.39%)',
                color: '#00FF00'
              }
            ]
          )
          message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'MSFT'))
        end
      end
    end
  end
end
