class Request
  include DataMapper::Resource

  property :id, Serial
  property :check_in_date, Date, required: true
  property :confirmed, Boolean, required: true, :default => false

  belongs_to :space
  belongs_to :user

  validates_with_method :check_in_date, :method => :is_within_available_dates?

  private

  def is_within_available_dates?
    return true if @check_in_date == ''
    if (@check_in_date > space.available_from && @check_in_date < space.available_until)
      true
    else
      [false, 'Check in date must be within available dates']
    end
  end
end
