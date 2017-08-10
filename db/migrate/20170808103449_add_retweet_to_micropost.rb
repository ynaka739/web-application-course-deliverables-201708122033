class AddRetweetToMicropost < ActiveRecord::Migration[5.0]
  def change
    add_reference :microposts, :retweet, index: true
  end
end
