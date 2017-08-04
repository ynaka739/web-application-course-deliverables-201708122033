module Search::UserSearch
  extend ActiveSupport::Concern
  included do
    scope :with_keyword, lambda { |keyword_string|
      table = User.arel_table
      keywords = generate_keyword(keyword_string)
      condition = nil
      keywords.each do |keyword|
        k = "%#{keyword}%"
        c = table[:name].matches(k)
        condition = condition.present? ? condition.or(c) : c
      end
      where(condition)
    }
    
    scope :with_email, lambda { |email|
      table = User.arel_table
      condition = table[:email].eq(email)
      where(condition)
    }
    
    scope :with_micropost_content, lambda { |keyword_string|
      table = Micropost.arel_table
      keywords = generate_keyword(keyword_string)
      condition = nil
      keywords.each do |keyword|
        k = "%#{keyword}%"
        c = table[:content].matches(k)
        condition = condition.present? ? condition.or(c) : c
      end
      where(condition)
    }
    
    scope :with_microposts, -> { joins(:microposts) }

    scope :search, lambda { |s|
      r = self
      r = r.with_keyword(s[:keyword]) if s[:keyword].present?
      r = r.with_email(s[:email]) if s[:email].present?
      r = r.with_microposts.with_micropost_content(s[:content]) if s[:content].present?
      return r if r != self
      where({})
    }
    
    
    def self.generate_keyword(keyword = nil)
      keyword ||= ''
      keyword.strip.split(/[ |\s]+/).map{ |str| ActiveSupport::Multibyte::Unicode.normalize(str, :kc)}
    end
  end
end