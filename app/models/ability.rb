class Ability
  include CanCan::Ability

  def initialize(user) # "CanCan expects a current_user method to exist in the controller"

    # Define abilities for the passed in user here. For example:
    # index, show, new, create, edit, update, destroy
    # index, show => :read
    # new, create => :create
    # edit, update => :update
    # destroy => :destroy

    if user.nil?
      return
    end

    # unless user.active_braintree
    #   can :manage,
    # end

    user ||= User.new # guest user (not logged in)

    #DINNER ON PHONE
    if user.role? USER_ROLE
      alias_action :get_message, :get_detail_message,:get_global_message, :get_restaurant_message,
        :get_unread_by_chain, :delete_message_by_restaurant, :delete_message, :to => :notification_actions
      alias_action :mypoint, :my_global_point, :point_detail, :point_share_friend, :reply_message, :to => :user_point_actions
      can :notification_actions, Notifications
      can :user_point_actions, UserPoint
      can :category_items, Category
      can :category_items_v1, Category
    end

    # RESTAURANT MANAGER
    if user.role? RTR_MANAGER_ROLE
      can :manage, Location do |l|
        has_location_role?(l, 'rsr_manager', user.id, false)
      end

      cannot :create, Location
      cannot :destroy, Location

      can :manage, Menu do |m|
        has_location_role?(m, 'rsr_manager', user.id, true)
      end
      can :manage, Category do |c|
        has_location_role?(c, 'rsr_manager', user.id, true)
      end
      can :manage, Server do |s|
        has_location_role?(s, 'rsr_manager', user.id, true)
      end
      can :manage, ItemKey do |ik|
        has_location_role?(ik, 'rsr_manager', user.id, true)
      end
      can :manage, Item do |i|
        has_location_role?(i, 'rsr_manager', user.id, true)
      end
      can :manage, Photo do |p|
        Photo.where(photoable_type: 'Location', photoable_id: user.restaurants.map(&:id)).include?(p)
      end

      can :manage, Notifications do |n|
        has_location_role?(n, 'rsr_manager', user.id, true) \
          || email_received?(n, user)
      end

      can :manage, UserPoint do |u|
        has_location_role?(u, 'rsr_manager', user.id, true)
      end
    end

    # RESTAURANT ADMIN
    if user.role? RTR_ADMIN_ROLE
      can :manage, Location do |l|
        has_location_role?(l, 'rsr_admin', user.id, false)
      end
      can :manage, Menu do |m|
        has_location_role?(m, 'rsr_admin', user.id, true)
      end
      can :manage, Category do |c|
        has_location_role?(c, 'rsr_admin', user.id, true)
      end
      can :manage, Server do |s|
        has_location_role?(s, 'rsr_admin', user.id, true)
      end
      can :manage, ItemKey do |ik|
        has_location_role?(ik, 'rsr_admin', user.id, true)
      end
      can :manage, Item do |i|
        has_location_role?(i, 'rsr_admin', user.id, true)
      end

      can :manage, Notifications do |n|
        has_location_role?(n, 'rsr_admin', user.id, true)
      end

      can :manage, UserPoint do |u|
        has_location_role?(u, 'rsr_admin', user.id, true)
      end

      can :manage, Admin::Package do |u|
      has_location_role?(u, 'rsr_admin', user.id, true)
      end
    end

    # OWNER
    if user.role? OWNER_ROLE
      can :manage, Location, :owner_id => user.id
      can :manage, Notifications do |n|
        location_owner?(n, user.id)
      end
      can :manage, Menu do |m|
        location_owner?(m, user.id)
      end
      can :manage, Category do |c|
        location_owner?(c, user.id)
      end
      can :manage, Server do |s|
        location_owner?(s, user.id)
      end
      can :manage, ItemKey do |ik|
        location_owner?(ik, user.id)
      end
      can :manage, Item do |i|
        location_owner?(i, user.id)
      end

      can :manage, UserPoint do |u|
        location_owner?(u, user.id)
      end
    end

    # ADMIN
    if user.role? ADMIN_ROLE
      can :manage, :all
    end
  end

  private
  def email_received?(notification, user)
    return notification.to_user == user.email
  end

  def has_location_role?(obj, permission, user_id, use_location)
    if obj.nil?
      return true
    end
    location = obj
    if use_location
      location = obj.location
    end
    unless location.nil?
      result = location.send(permission)
      return result.split(',').map(&:to_i).include?(user_id) unless result.nil?
    end
    return true
  end

  def location_owner?(obj, user_id)
    unless obj.new_record?
      obj.location.owner_id == user_id
    end
  end
end
