class User < ActiveRecord::Base
  has_many :orders

  has_secure_password
  validates :email, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create }
  validates :email, uniqueness: true
  validates :password, confirmation: true


  before_create { generate_token :auth_token }

  def generate_token column
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def pending_orders
    orders.where(transcript: :nil)
  end

  def save_stripe_customer stripe_card_token
    stripe_customer_token = Stripe::Customer.create(description: "#{email} added a card.", source: stripe_card_token)
    self.stripe_token = stripe_customer_token.id
    self.save!
  end
end
