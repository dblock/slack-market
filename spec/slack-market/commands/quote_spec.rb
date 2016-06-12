require 'spec_helper'

describe SlackMarket::Commands::Quote do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:message_command) { SlackRubyBot::Hooks::Message.new }
  context 'quote' do
    it 'returns a quote for MSFT', vcr: { cassette_name: 'msft', allow_playback_repeats: true } do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        attachments: [
          {
            fallback: 'Microsoft Corporation (MSFT): $51.91',
            title_link: 'http://finance.yahoo.com/q?s=MSFT',
            title: 'Microsoft Corporation (MSFT)',
            text: '$51.91 (-0.48%)',
            color: '#FF0000',
            image_url: 'http://chart.finance.yahoo.com/z?s=MSFT&z=l'
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
            title_link: 'http://finance.yahoo.com/q?s=MSFT',
            title: 'Microsoft Corporation (MSFT)',
            text: '$51.91 (-0.48%)',
            color: '#FF0000',
            image_url: 'http://chart.finance.yahoo.com/z?s=MSFT&z=l'
          }
        ]
      ).twice
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$MSFT?'))
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $MSFT?"))
    end
    it 'returns a quote for ROG.VX', vcr: { cassette_name: 'rog.vx', allow_playback_repeats: true } do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        attachments: [
          {
            fallback: 'ROCHE HLDG DR (ROG.VX): $248.50',
            title_link: 'http://finance.yahoo.com/q?s=ROG.VX',
            title: 'ROCHE HLDG DR (ROG.VX)',
            text: '$248.50 (+0.53%)',
            color: '#00FF00',
            image_url: 'http://chart.finance.yahoo.com/z?s=ROG.VX&z=l'
          }
        ]
      ).exactly(4).times
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'ROG.VX'))
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's ROG.VX?"))
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$ROG.VX?'))
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $ROG.VX?"))
    end
    it 'returns a quote for MSFT and YHOO', vcr: { cassette_name: 'msft_yahoo_invalid' } do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        attachments: [
          {
            fallback: 'Microsoft Corporation (MSFT): $50.16',
            title_link: 'http://finance.yahoo.com/q?s=MSFT',
            title: 'Microsoft Corporation (MSFT)',
            text: '$50.16 (-3.54%)',
            color: '#FF0000',
            image_url: 'http://chart.finance.yahoo.com/z?s=MSFT&z=l'
          },
          {
            fallback: 'Yahoo! Inc. (YHOO): $27.97',
            title_link: 'http://finance.yahoo.com/q?s=YHOO',
            title: 'Yahoo! Inc. (YHOO)',
            text: '$27.97 (-4.05%)',
            color: '#FF0000',
            image_url: 'http://chart.finance.yahoo.com/z?s=YHOO&z=l'
          }
        ]
      )
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's MSFT or YHOO and INVALID?"))
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
    it 'returns a quote for a single-character $stock', vcr: { cassette_name: 'f' } do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        attachments: [
          {
            fallback: 'Ford Motor Company Common Stock (F): $11.45',
            title_link: 'http://finance.yahoo.com/q?s=F',
            title: 'Ford Motor Company Common Stock (F)',
            text: '$11.45 (0.69%)',
            color: '#00FF00',
            image_url: 'http://chart.finance.yahoo.com/z?s=F&z=l'
          }
        ]
      )
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $F?"))
    end
    it 'returns a quote for a single-character stock$', vcr: { cassette_name: 'f' } do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        attachments: [
          {
            fallback: 'Ford Motor Company Common Stock (F): $11.45',
            title_link: 'http://finance.yahoo.com/q?s=F',
            title: 'Ford Motor Company Common Stock (F)',
            text: '$11.45 (0.69%)',
            color: '#00FF00',
            image_url: 'http://chart.finance.yahoo.com/z?s=F&z=l'
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
              title_link: 'http://finance.yahoo.com/q?s=MSFT',
              title: 'Microsoft Corporation (MSFT)',
              text: '$51.91 (-0.48%)',
              color: '#FF0000',
              image_url: 'http://chart.finance.yahoo.com/z?s=MSFT&z=l'
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
              title_link: 'http://finance.yahoo.com/q?s=MSFT',
              title: 'Microsoft Corporation (MSFT)',
              text: '$51.91 (-0.48%)',
              color: '#FF0000'
            }
          ]
        )
        message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'MSFT'))
      end
    end
    it 'returns a quote for $CMO-PE', vcr: { cassette_name: 'cmo-pe', allow_playback_repeats: true } do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        attachments: [
          {
            fallback: 'Capstead Mortgage Corporation P (CMO-PE): $24.765',
            title_link: 'http://finance.yahoo.com/q?s=CMO-PE',
            title: 'Capstead Mortgage Corporation P (CMO-PE)',
            text: '$24.765 (+0.081%)',
            color: '#00FF00',
            image_url: 'http://chart.finance.yahoo.com/z?s=CMO-PE&z=l'
          }
        ]
      ).exactly(4).times
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'CMO-PE?'))
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's CMO-PE?"))
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: '$CMO-PE?'))
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "How's $CMO-PE?"))
    end
  end
end
