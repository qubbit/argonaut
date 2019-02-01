defmodule Argonaut.Factory do
  use ExMachina.Ecto, repo: Argonaut.Repo

  def user_factory do
    %Argonaut.User{
      first_name: "John",
      last_name: "Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      username: sequence(:username, &"username#{&1}")
    }
  end

  def team_factory do
    %Argonaut.Team{name: sequence(:name, &"team-name-#{&1}")}
  end

  def application_factory do
    %Argonaut.Application{
      name: sequence(:name, &"app-name-#{&1}"),
      ping: "ping_url",
      repo: "repo_url",
      team: build(:team)
    }
  end

  def environment_factory do
    %Argonaut.Environment{
      name: sequence(:name, &"env-name-#{&1}"),
      description: "A testing environment",
      team: build(:team)
    }
  end

  def reservation_factory do
    %Argonaut.Reservation{
      reserved_at: DateTime.utc_now(),
      application: build(:application),
      environment: build(:environment),
      team: build(:team),
      user: build(:user)
    }
  end

  def reminder_factory do
    %Argonaut.Reminder{
      reservation: build(:reservation),
      reminded_at: DateTime.utc_now
    }
  end

  def expired_reservation_with_reminder_factory do
    struct!(
      expired_reservation_factory(),
      %{
        reminder: build(:reminder)
      }
    )
  end

  def expired_reservation_with_expired_reminder_factory do
    struct!(
      expired_reservation_factory(),
      %{
        reminder: build(:expired_reminder)
      }
    )
  end

  def expired_reminder_factory do
    struct!(
      reminder_factory(),
      %{
        reminded_at:
          Timex.subtract(
            DateTime.utc_now(),
            %Timex.Duration{megaseconds: 0, seconds: 8000, microseconds: 0}
          )
      }
    )
  end

  def expired_reservation_factory do
    struct!(
      reservation_factory(),
      %{
        reserved_at:
          Timex.subtract(
            DateTime.utc_now(),
            %Timex.Duration{megaseconds: 0, seconds: 90000, microseconds: 0}
          )
      }
    )
  end

  def admin_user_factory do
    struct!(
      user_factory(),
      %{
        is_admin: true
      }
    )
  end
end
