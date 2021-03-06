alias Argonaut.{Application, Environment, User, Reservation, Team, Membership, Repo}

# users
gopal =
  Repo.insert!(
    User.registration_changeset(%User{}, %{
      username: "gadhikari",
      password: "abcd1234",
      email: "g@example.com",
      is_admin: true,
      time_zone: "America/New_York"
    })
  )

wade =
  Repo.insert!(
    User.registration_changeset(%User{}, %{
      username: "wjohnson",
      password: "changeme",
      email: "w@example.com",
      time_zone: "American/Chicago"
    })
  )

chris =
  Repo.insert!(
    User.registration_changeset(%User{}, %{
      username: "cdoggett",
      password: "changeme",
      email: "c@example.com",
      time_zone: "America/Chicago"
    })
  )

# teams
team_changeset =
  Team.changeset(%Team{}, %{name: "EPA", description: "Whatever", logo_url: "whatever"})
  |> Ecto.Changeset.put_assoc(:owner, gopal)

epa_team = Repo.insert!(team_changeset)

# membership
Repo.insert!(%Membership{
  user_id: gopal.id,
  team_id: epa_team.id,
  is_admin: true,
  join_date: DateTime.utc_now()
})

Repo.insert!(%Membership{user_id: wade.id, team_id: epa_team.id, join_date: DateTime.utc_now()})
Repo.insert!(%Membership{user_id: chris.id, team_id: epa_team.id, join_date: DateTime.utc_now()})

# testing environments
pbm1 =
  Repo.insert!(
    Environment.changeset(%Environment{}, %{
      name: "pbm1",
      description: "PBM1",
      team_id: epa_team.id
    })
    |> Ecto.Changeset.put_assoc(:team, epa_team)
  )

epa1 =
  Repo.insert!(
    Environment.changeset(%Environment{}, %{
      name: "epa1",
      description: "EPA1",
      team_id: epa_team.id
    })
    |> Ecto.Changeset.put_assoc(:team, epa_team)
  )

epa2 =
  Repo.insert!(
    Environment.changeset(%Environment{}, %{
      name: "epa2",
      description: "EPA2",
      team_id: epa_team.id
    })
    |> Ecto.Changeset.put_assoc(:team, epa_team)
  )

Repo.insert!(
  Environment.changeset(%Environment{}, %{
    name: "perf3",
    description: "EPA performance testing environment",
    team_id: epa_team.id
  })
  |> Ecto.Changeset.put_assoc(:team, epa_team)
)

# apps
admin =
  Repo.insert!(%Application{
    name: "admin",
    repo: "pbm/autobahn",
    team_id: epa_team.id,
    ping: "_ping"
  })

Repo.insert!(%Application{
  name: "dashboard",
  repo: "pbm/dashboard",
  team_id: epa_team.id,
  ping: "_ping"
})

epamotron =
  Repo.insert!(%Application{
    name: "epamotron",
    repo: "pbm/epamotron",
    team_id: epa_team.id,
    ping: "_ping"
  })

Repo.insert!(%Application{
  name: "eligibility",
  repo: "pbm/eligibility_gateway",
  team_id: epa_team.id,
  ping: "_ping"
})

epa_gateway =
  Repo.insert!(%Application{
    name: "epa_gateway",
    repo: "pbm/epa_gateway",
    team_id: epa_team.id,
    ping: "_ping"
  })

Repo.insert!(%Application{
  name: "pbmproxy",
  repo: "pbm/pbmproxy",
  ping: "_ping",
  team_id: epa_team.id
})

Repo.insert!(%Application{
  name: "fake-plan-payer",
  repo: "pbm/fake-plan-payer",
  team_id: epa_team.id,
  ping: "_ping"
})

Repo.insert!(%Application{
  name: "formbuilder",
  repo: "pbm/formbuilder",
  team_id: epa_team.id,
  ping: "_ping"
})

Repo.insert!(%Application{
  name: "pa-starter",
  repo: "pbm/pa-starter",
  team_id: epa_team.id,
  ping: "_ping"
})

Repo.insert!(%Application{
  name: "pdfmotron",
  repo: "pbm/pdfmotron",
  team_id: epa_team.id,
  ping: "_ping"
})

Repo.insert!(%Application{
  name: "renewals-api",
  repo: "pbm/renewals-api",
  team_id: epa_team.id,
  ping: "_ping"
})

Repo.insert!(%Application{
  name: "request-updater",
  repo: "pbm/request-updater",
  team_id: epa_team.id,
  ping: "_ping"
})

# reservations
Repo.insert!(
  Reservation.changeset(%Reservation{}, %{
    user_id: gopal.id,
    reserved_at: DateTime.utc_now(),
    application_id: epamotron.id,
    team_id: epa_team.id,
    environment_id: pbm1.id
  })
)

Repo.insert!(
  Reservation.changeset(%Reservation{}, %{
    user_id: wade.id,
    reserved_at: DateTime.utc_now(),
    application_id: admin.id,
    team_id: epa_team.id,
    environment_id: pbm1.id
  })
)

Repo.insert!(
  Reservation.changeset(%Reservation{}, %{
    user_id: gopal.id,
    reserved_at: DateTime.utc_now(),
    application_id: epa_gateway.id,
    team_id: epa_team.id,
    environment_id: epa1.id
  })
)

Repo.insert!(
  Reservation.changeset(%Reservation{}, %{
    user_id: chris.id,
    reserved_at: DateTime.utc_now(),
    application_id: epamotron.id,
    team_id: epa_team.id,
    environment_id: epa2.id
  })
)
