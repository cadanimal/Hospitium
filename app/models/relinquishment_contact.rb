class RelinquishmentContact < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include CommonScopes
  include PublicActivity::Model
  tracked owner: -> controller, model { controller.current_user }, 
          recipient: -> controller, model { controller.current_user.organization }, 
          params: {
            author_name: -> controller, model { controller.current_user.username },
            author_email: -> controller, model { controller.current_user.email },
            object_name: -> controller, model { "#{model.first_name} #{model.last_name}" },
            summary: -> controller, model { model.changes }
          }
  
  has_many :relinquish_animals
  has_many :animals, through: :relinquish_animals
  belongs_to :organization
  before_create :modify_phone_number
  before_update :modify_phone_number

  attr_accessible :first_name, :last_name, :address, :phone, :email, :reason
  
  validates_presence_of :first_name, :last_name, :organization_id
  
  def show_name_label_method
    "#{self.first_name} #{self.last_name}"
  end
  
  def modify_phone_number
    self.phone = self.phone.delete('^0-9') unless self.phone.blank?
  end
  
  def formatted_phone
    self.phone.blank? ? '' : number_to_phone(self.phone)
  end

  # ===============
  # = CSV support =
  # ===============
  comma do
    id 'ID'
    first_name 'First Name'
    last_name 'Last Name'
    address 'Address'
    phone 'Phone'
    email 'Email'
    reason 'Reason'
    animals 'Relinquished Animal IDs' do |a| a.map{|a| a.id}.join(',') end
  end
end
