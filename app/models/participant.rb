class Participant < ApplicationRecord
    belongs_to :event
    belongs_to :account_expanded
    validates :entry_status, numericality:{message:'を選択肢から選択してください。', only_integer:true, greater_than_or_equal_to:0, less_than:ENTRY_STATUS_ARRAY.length}
    validates :participation_status, numericality:{message:'を選択肢から選択してください。', only_integer:true, greater_than_or_equal_to:0, less_than:PARTICIPATION_STATUS_ARRAY.length}
end
