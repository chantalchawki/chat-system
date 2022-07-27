class Message < ApplicationRecord
  self.locking_column = :lock_message

  belongs_to :chat

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "message_index"

  settings index: {
    analysis: {
      analyzer: {
        autocomplete: {
          tokenizer: "autocomplete",
          filter: [
            "lowercase"
          ]
        },
        autocomplete_search: {
          tokenizer: "lowercase"
        }
      },
      tokenizer: {
        autocomplete: {
          type: "edge_ngram",
          min_gram: 2,
          max_gram: 10,
          token_chars: [
            "letter"
          ]
        }
      }
    }
  } do
      mapping do
        indexes :body, type: "text", analyzer: "autocomplete", search_analyzer: "autocomplete_search"
        indexes :chat_id, type: "integer"
        indexes :number, type: "integer"
      end
    end

  def self.search(query, chat_id)
    puts query
    puts chat_id
    __elasticsearch__.search(
      {
        query: {
          bool: {
            must: [
              {
                match: {
                  body: query
                }
              },
              {
                match: {
                  chat_id: chat_id
                }
              }
            ]
          }
        }
      }
    )
  end

  def as_indexed_json(options = nil)
    self.as_json( only: [ :chat_id, :body, :number] )
  end
end
Message.import(force: true)