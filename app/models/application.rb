class Application < ApplicationRecord
    self.locking_column = :lock_application

    has_secure_token
    has_many :chat
end
