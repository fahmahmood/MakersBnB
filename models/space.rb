require 'data_mapper'


class Space
  include DataMapper::Resource

  property :id, Serial
  property :name, String, required: true
  property :description, Text, required: true
  property :price, Integer, required: true
  property :available_from, Date, required: true
  property :available_until, Date, required: true

  validates_with_method :available_from, :method => :is_from_date_after_today?
  validates_with_method :available_until, :method => :is_until_date_after_from_date?

  belongs_to :user
  has n, :requests

  private
  def is_from_date_after_today?
    return true if @available_from == ""
    if @available_from > Date.today
      true
    else
      [false, "The available from date must be in the future"]
    end
  end

  def is_until_date_after_from_date?
    return true if (@available_until == '' || @available_from == '')
    if @available_until > @available_from
      true
    else
      [false, "The until date must come after the from date"]
    end
  end

end
