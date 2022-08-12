# frozen_string_literal: true

class AddEmailsColumnToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email, :string
  end
end
