defmodule Argonaut.SlackNotifierTest do
  use ExUnit.Case, async: false

  import Mock
  import Argonaut.Factory

  alias Argonaut.SlackNotifier
  alias Argonaut.SlackApi
  alias Argonaut.Repo
  alias Argonaut.Reminder

  setup do
    # TODO: find out how to reset DB after tests run
    Repo.delete_all(Argonaut.Environment)
    Repo.delete_all(Argonaut.Team)
    Repo.delete_all(Argonaut.User)

    :ok
  end

  describe "work" do
    test "does not notify users for reservations less than 24 hours old" do
      insert(:reservation)
      insert(:reservation)
      insert(:reservation)
      assert 0 = SlackNotifier.work(true)
    end

    test "notifies users about reservations over 24 hours that do not have reminders" do
      res = insert(:expired_reservation)
      notif_message = "Are you still using *#{res.environment.name}:#{res.application.name}*?"

      with_mock SlackApi,
        send_notification: fn message, username, reminder_id, reservation_id ->
          :notification_sent
        end do
        assert 1 = SlackNotifier.work(true)

        reminder = Repo.one(Reminder, reservation_id: res.id)

        :notification_sent =
          SlackApi.send_notification(notif_message, "#{res.user.username}", reminder.id, res.id)
      end
    end

    test "does notify users about reservations over 24 hours when the reminder was sent less than two hours ago" do
      res = insert(:expired_reservation_with_reminder)
      assert 0 = SlackNotifier.work(true)
    end

    test "notifies users for reservations over 24 hours that have reminders with expired grace period" do
      res = insert(:expired_reservation_with_expired_reminder)
      notif_message = "Are you still using *#{res.environment.name}:#{res.application.name}*?"

      with_mock SlackApi,
        send_notification: fn message, username, reminder_id, reservation_id ->
          :notification_sent
        end do
        assert 1 = SlackNotifier.work(true)

        :notification_sent =
          SlackApi.send_notification(
            notif_message,
            "#{res.user.username}",
            res.reminder.id,
            res.id
          )
      end
    end
  end
end
