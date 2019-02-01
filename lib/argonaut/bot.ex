defmodule Argonaut.Bot do
  alias Argonaut.Reservations

  @env_app_re "(?<env>[\\w-]+):(?<app>[\\w-]+)"
  # handle im, i'm, i am
  @i_am_re "I(?:'m|m| am)"
  # handle whos, who's, who is
  @who_is_re "Who(?:'s|s| is)"

  @matchers [
    {:reservation_action, ~r/#{@env_app_re} (?<action>info|release|renew|reserve)/i},
    {:reservation_info, ~r/#{@who_is_re} using #{@env_app_re}(\?)?/i},
    {:reservation_release, ~r/#{@i_am_re} done (with|using) #{@env_app_re}/i},
    {:reservation_renew, ~r/#{@i_am_re} still using #{@env_app_re}/i},
    {:reservation_reserve, ~r/#{@i_am_re} using #{@env_app_re}(for (?<reason>.*))?/i},
    {:list_environments, ~r/\A(?<action>show|list) (?<thing>envs|environments)\z/i},
    {:list_teams, ~r/\A(?<action>show|list) (?<thing>teams)\z/i},
    {:list_team_info, ~r/(?<action>show|list) team (?<name_or_id>.+)/i}
  ]

  @default_handler {:default_handler, nil}

    def list_team_info(%{"name_or_id" => name_or_id} = params, user) do
    Reservations.list_team_info(params)
  end

  def list_environments(params) do
    # Reservations.list_environments()
  end

  def list_teams(params) do
    # Reservations.list_environments()
  end

  def reply(%{message: message, user: user}) do
    {action, regex} =
      Enum.find(@matchers, @default_handler, fn {_, re} -> Regex.match?(re, message) end)

    if action == :default_handler do
      apply(__MODULE__, action, [])
    else
      matches = Regex.named_captures(regex, message)
      apply(__MODULE__, action, [matches, user])
    end
  end

  def reservation_action(%{"action" => action, "app" => app, "env" => env} = params, user) do
    action_function = String.to_existing_atom("reservation_#{action}")

    apply(__MODULE__, action_function, [params, user])
  end

  def reservation_info(%{"app" => app, "env" => env} = params, _) do
    Reservations.reservation_info(params)
  end

  def reservation_release(%{"app" => app, "env" => env} = params, user) do
    Reservations.delete_reservation(params, user)
  end

  def reservation_renew(%{"app" => app, "env" => env}, user) do
    %{success: true, message: "Renewing #{env} #{app}"}
  end

  def reservation_reserve(%{"app" => app, "env" => env} = params, user) do
    Reservations.create_reservation(params, user)
  end

  def default_handler do
    %{
      success: :unknown,
      message: ~s"""
      Hmm, I don't know what you mean.

      Here are the things I can help you with:

      *To reserve a testing environment*: I am using _env_:_app_ [for _reason_]
      *To release a testing environment*: I am done using _env_:_app_
      *Get information about an environment*: Who is using _env_:_app_?

      Shorthand:
      _env_:_app_ <reserve | release | info>
      """
    }
  end
end
