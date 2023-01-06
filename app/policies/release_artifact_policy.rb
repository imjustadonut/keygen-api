# frozen_string_literal: true

class ReleaseArtifactPolicy < ApplicationPolicy
  skip_pre_check :verify_authenticated!, only: %i[index? show? download?]

  scope_for :active_record_relation do |relation|
    relation = relation.for_environment(environment) if
      relation.respond_to?(:for_environment)

    case bearer
    in role: { name: 'admin' | 'developer' | 'read_only' | 'sales_agent' | 'support_agent' }
      relation.all
    in role: { name: 'product' } if relation.respond_to?(:for_product)
      relation.for_product(bearer.id)
    in role: { name: 'user' } if relation.respond_to?(:for_user)
      relation.for_user(bearer.id)
              .published
              .uploaded
    in role: { name: 'license' } if relation.respond_to?(:for_license)
      relation.for_license(bearer.id)
              .published
              .uploaded
    else
      relation.open
              .published
              .uploaded
    end
  end

  def index?
    verify_permissions!('artifact.read')

    allow? :index, record.collect(&:release), skip_verify_permissions: true, with: ::ReleasePolicy
  end

  def show?
    verify_permissions!('artifact.read')

    allow? :show, record.release, skip_verify_permissions: true, with: ::ReleasePolicy
  end

  def create?
    verify_permissions!('artifact.create')

    case bearer
    in role: { name: 'admin' | 'developer' }
      allow!
    in role: { name: 'product' } if record.product == bearer
      allow!
    else
      deny!
    end
  end

  def update?
    verify_permissions!('artifact.update')

    case bearer
    in role: { name: 'admin' | 'developer' }
      allow!
    in role: { name: 'product' } if record.product == bearer
      allow!
    else
      deny!
    end
  end

  def destroy?
    verify_permissions!('artifact.delete')

    case bearer
    in role: { name: 'admin' | 'developer' }
      allow!
    in role: { name: 'product' } if record.product == bearer
      allow!
    else
      deny!
    end
  end
end
