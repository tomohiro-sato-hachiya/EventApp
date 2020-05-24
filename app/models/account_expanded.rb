class AccountExpanded < ApplicationRecord
    belongs_to :account
    has_many :events
    has_many :participants

    validates :name, presence: {message:'は、必須項目です。'}
end
