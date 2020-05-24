require "time"

class Event < ApplicationRecord
    belongs_to :account_expanded
    has_many :comments
    has_many :participants
    has_rich_text :detail
    validates :name, presence:{message:'は、必須項目です。'}
    validates :detail, presence:{message:'は、必須項目です。'}
    validates :place_id, presence:{message:'は、必須項目です。'}, numericality:{message:'を選択肢から選択してください。', only_integer:true, greater_than_or_equal_to:0, less_than:PLACE_ID_ARRAY.length}
    validates :event_start_datetime, presence:{message:'は、必須項目です。'}
    validates :event_end_datetime, presence:{message:'は、必須項目です。'}
    validates :entry_start_datetime, presence:{message:'は、必須項目です。'}
    validates :entry_end_datetime, presence:{message:'は、必須項目です。'}
    validates :participant_limit, presence:{message:'は、必須項目です。'}, numericality:{message:'は、1以上の整数でなければいけません。', only_integer:true, greater_than_or_equal_to:1}
    validate :event_start_end_check
    validate :entry_event_start_check
    validate :entry_event_end_check
    validate :entry_start_end_check

    def event_start_end_check
        errors.add(:event_start_datetime, "の値が不正です。") unless
        self.event_start_datetime <= self.event_end_datetime
    end

    def entry_event_start_check
        errors.add(:entry_start_datetime, "の値が不正です。") unless
        self.entry_start_datetime <= self.event_start_datetime
    end

    def entry_event_end_check
        errors.add(:entry_end_datetime, "の値が不正です。") unless
        self.entry_end_datetime <= self.event_end_datetime
    end

    def entry_start_end_check
        errors.add(:entry_start_datetime, "の値が不正です。") unless
        self.entry_start_datetime <= self.entry_end_datetime
    end
end
