require 'spec_helper'

describe SlackMarket::Commands::Quote do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:message_command) { SlackRubyBot::Hooks::Message.new }
  context 'quote' do
    it 'requires a subscription', vcr: { cassette_name: 'msft' } do
      expect(message: 'MSFT').to respond_with_slack_message([
        'Not showing quotes for Microsoft Corporation (MSFT).',
        team.subscribe_text
      ].join(' '))
    end
    it 'requires a subscription for MSFT and AABA and INVALID', vcr: { cassette_name: 'msft_yahoo_invalid' } do
      expect(message: 'MSFT and AABA or INVALID').to respond_with_slack_message([
        'Not showing quotes for Microsoft Corporation (MSFT) or Altaba Inc (AABA).',
        team.subscribe_text
      ].join(' '))
    end
    context 'subscribed team' do
      let(:team) { Fabricate(:team, subscribed: true) }
      it 'returns a quote for MSFT', vcr: { cassette_name: 'msft', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Microsoft Corporation (MSFT): $51.91',
              title_link: 'http://finance.google.com/q=MSFT',
              title: 'Microsoft Corporation (MSFT)',
              text: '$51.91 (+0.11%)',
              color: '#00FF00',
              callback_id: 'Microsoft Corporation',
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
              image_url: 'https://www.google.com/finance/getchart?q=MSFT&i=360'
            }
          ]
        ).twice
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'MSFT'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's MSFT?"))
      end
      it 'does not repeat stocks', vcr: { cassette_name: 'msft', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).once
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'MSFT MSFT'))
      end
      it 'returns a quote for $MSFT', vcr: { cassette_name: 'msft', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Microsoft Corporation (MSFT): $51.91',
              title_link: 'http://finance.google.com/q=MSFT',
              title: 'Microsoft Corporation (MSFT)',
              text: '$51.91 (+0.11%)',
              color: '#00FF00',
              callback_id: 'Microsoft Corporation',
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
              image_url: 'https://www.google.com/finance/getchart?q=MSFT&i=360'
            }
          ]
        ).exactly(3).times
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$MSFT?'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $MSFT?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $msft?"))
      end
      it 'returns a quote for ROG.VX', vcr: { cassette_name: 'rog.vx', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Roche Holding Ltd. (ROG): $232.7',
              title_link: 'http://finance.google.com/q=ROG',
              title: 'Roche Holding Ltd. (ROG)',
              text: '$232.7 (+0.34%)',
              color: '#00FF00',
              callback_id: 'Roche Holding Ltd.',
              actions: [
                {
                  name: '1D',
                  text: '1d',
                  type: 'button',
                  value: 'ROG- 1d'
                },
                {
                  name: '1M',
                  text: '1m',
                  type: 'button',
                  value: 'ROG- 1m'
                },
                {
                  name: '1Y',
                  text: '1y',
                  type: 'button',
                  value: 'ROG- 1y'
                }
              ],
              image_url: 'https://www.google.com/finance/getchart?q=ROG&i=360'
            }
          ]
        ).exactly(6).times
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'ROG.VX'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's ROG.VX?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$ROG.VX?'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $ROG.VX?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$rog.vx?'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $rog.VX?"))
      end
      it 'returns a quote for 0941.HK', vcr: { cassette_name: '0941.hk', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'China Mobile Ltd. (0941): $78.85',
              title_link: 'http://finance.google.com/q=0941',
              title: 'China Mobile Ltd. (0941)',
              text: '$78.85 (+0.32%)',
              color: '#00FF00',
              callback_id: 'China Mobile Ltd.',
              actions: [
                {
                  name: '1D',
                  text: '1d',
                  type: 'button',
                  value: '0941- 1d'
                },
                {
                  name: '1M',
                  text: '1m',
                  type: 'button',
                  value: '0941- 1m'
                },
                {
                  name: '1Y',
                  text: '1y',
                  type: 'button',
                  value: '0941- 1y'
                }
              ],
              image_url: 'https://www.google.com/finance/getchart?q=0941&i=360'
            }
          ]
        ).exactly(5).times
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '0941.HK'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's 0941.HK?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$0941.HK?'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $0941.HK?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$0941.hk?'))
      end
      it 'returns a quote for Z74.SI', vcr: { cassette_name: 'z74.si', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Singapore Telecommunications Ltd. (Z74): $3.77',
              title_link: 'http://finance.google.com/q=Z74',
              title: 'Singapore Telecommunications Ltd. (Z74)',
              text: '$3.77 (+0.53%)',
              color: '#00FF00',
              callback_id: 'Singapore Telecommunications Ltd.',
              actions: [
                {
                  name: '1D',
                  text: '1d',
                  type: 'button',
                  value: 'Z74- 1d'
                },
                {
                  name: '1M',
                  text: '1m',
                  type: 'button',
                  value: 'Z74- 1m'
                },
                {
                  name: '1Y',
                  text: '1y',
                  type: 'button',
                  value: 'Z74- 1y'
                }
              ],
              image_url: 'https://www.google.com/finance/getchart?q=Z74&i=360'
            }
          ]
        ).exactly(6).times
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'Z74.SI'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's Z74.SI?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$Z74.SI?'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $Z74.SI?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$z74.si?'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $z74.SI?"))
      end
      it 'returns a quote for 300024.SZ (no name)', vcr: { cassette_name: '300024.sz', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Siasun Robot&Automation Co Ltd (300024): $20.16',
              title_link: 'http://finance.google.com/q=300024',
              title: 'Siasun Robot&Automation Co Ltd (300024)',
              text: '$20.16 (-0.05%)',
              color: '#FF0000',
              callback_id: 'Siasun Robot&Automation Co Ltd',
              actions: [
                {
                  name: '1D',
                  text: '1d',
                  type: 'button',
                  value: '300024- 1d'
                },
                {
                  name: '1M',
                  text: '1m',
                  type: 'button',
                  value: '300024- 1m'
                },
                {
                  name: '1Y',
                  text: '1y',
                  type: 'button',
                  value: '300024- 1y'
                }
              ],
              image_url: 'https://www.google.com/finance/getchart?q=300024&i=360'
            }
          ]
        ).exactly(1).times
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$300024.SZ?'))
      end
      it 'returns a quote for MSFT and AABA', vcr: { cassette_name: 'msft_yahoo_invalid' } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Microsoft Corporation (MSFT): $84.14',
              title_link: 'http://finance.google.com/q=MSFT',
              title: 'Microsoft Corporation (MSFT)',
              text: '$84.14 (+0.11%)',
              color: '#00FF00',
              callback_id: 'Microsoft Corporation',
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
              image_url: 'https://www.google.com/finance/getchart?q=MSFT&i=360'
            },
            {
              fallback: 'Altaba Inc (AABA): $70.23',
              title_link: 'http://finance.google.com/q=AABA',
              title: 'Altaba Inc (AABA)',
              text: '$70.23 (-0.40%)',
              color: '#FF0000',
              callback_id: 'Altaba Inc',
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
              image_url: 'https://www.google.com/finance/getchart?q=AABA&i=360'
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
      it 'returns a quote for a single-character $stock', vcr: { cassette_name: 'f', allow_playback_repeats: true } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Ford Motor Company (F): $12.36',
              title_link: 'http://finance.google.com/q=F',
              title: 'Ford Motor Company (F)',
              text: '$12.36 (-0.48%)',
              color: '#FF0000',
              callback_id: 'Ford Motor Company',
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
              image_url: 'https://www.google.com/finance/getchart?q=F&i=360'
            }
          ]
        ).exactly(4).times
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $F?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $f?"))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$f'))
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$F'))
      end
      it 'returns a quote for a single-character stock$', vcr: { cassette_name: 'f' } do
        expect(client.web_client).to receive(:chat_postMessage).with(
          channel: 'channel',
          as_user: true,
          attachments: [
            {
              fallback: 'Ford Motor Company (F): $12.36',
              title_link: 'http://finance.google.com/q=F',
              title: 'Ford Motor Company (F)',
              text: '$12.36 (-0.48%)',
              color: '#FF0000',
              callback_id: 'Ford Motor Company',
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
              image_url: 'https://www.google.com/finance/getchart?q=F&i=360'
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
        it 'returns a quote for $MSFT', vcr: { cassette_name: 'msft' } do
          expect(client.web_client).to receive(:chat_postMessage).with(
            channel: 'channel',
            as_user: true,
            attachments: [
              {
                fallback: 'Microsoft Corporation (MSFT): $51.91',
                title_link: 'http://finance.google.com/q=MSFT',
                title: 'Microsoft Corporation (MSFT)',
                text: '$51.91 (+0.11%)',
                color: '#00FF00',
                callback_id: 'Microsoft Corporation',
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
                image_url: 'https://www.google.com/finance/getchart?q=MSFT&i=360'
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
        it 'returns a quote for MSFT without a chart', vcr: { cassette_name: 'msft' } do
          expect(client.web_client).to receive(:chat_postMessage).with(
            channel: 'channel',
            as_user: true,
            attachments: [
              {
                fallback: 'Microsoft Corporation (MSFT): $51.91',
                title_link: 'http://finance.google.com/q=MSFT',
                title: 'Microsoft Corporation (MSFT)',
                text: '$51.91 (+0.11%)',
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
