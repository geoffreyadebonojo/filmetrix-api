# frozen_string_literal: true

module Types
  class D3::ResponseType < Types::BaseObject
    field :status, Integer, null: false
    field :msg, String, null: false
    field :resource_id, String, null: true
    field :resource_slug, String, null: true
  end
end
