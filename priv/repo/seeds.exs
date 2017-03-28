alias Argonaut.{Application, Environment, User, Reservation, Team, Membership, Repo}

# users
gopal = Repo.insert!(User.registration_changeset(%User{}, %{username: "gadhikari", password: "abcd1234", email: "g@example.com", is_admin: true, time_zone: "America/New_York"}))

wade = Repo.insert!(User.registration_changeset(%User{}, %{username: "wjohnson", password: "changeme", email: "w@example.com", time_zone: "American/Chicago"}))

chris = Repo.insert!(User.registration_changeset(%User{}, %{username: "cdoggett", password: "changeme", email: "c@example.com", time_zone: "America/Chicago"}))


# teams
team_changeset = Team.changeset(%Team{}, %{name: "EPA",
                          description: "Whatever",
                          logo_url: "whatever"}) |> Ecto.Changeset.put_assoc(:owner, gopal)

epa_team = Repo.insert!(team_changeset)

# membership
Repo.insert!(%Membership{user_id: gopal.id, team_id: epa_team.id, is_admin: true, join_date: Ecto.DateTime.utc})
Repo.insert!(%Membership{user_id: wade.id, team_id: epa_team.id, join_date: Ecto.DateTime.utc})
Repo.insert!(%Membership{user_id: chris.id, team_id: epa_team.id, join_date: Ecto.DateTime.utc})

# testing environments
pbm1  = Repo.insert!(Environment.changeset(%Environment{}, %{name: "pbm1", description: "PBM1"}) |> Ecto.Changeset.put_assoc(:team, epa_team))

epa1  = Repo.insert!(Environment.changeset(%Environment{}, %{name: "epa1", description: "EPA1"}) |> Ecto.Changeset.put_assoc(:team, epa_team))

epa2  = Repo.insert!(Environment.changeset(%Environment{}, %{name: "epa2", description: "EPA2"}) |> Ecto.Changeset.put_assoc(:team, epa_team))

perf3  = Repo.insert!(Environment.changeset(%Environment{}, %{name: "perf3", description: "EPA performance testing environment"}) |> Ecto.Changeset.put_assoc(:team, epa_team))

# apps
admin = Repo.insert!(%Application{name: "admin",
                                  repo: "pbm/autobahn",
                                  ping: "_ping"})

Repo.insert!(%Application{name: "dashboard",
                                      repo: "pbm/dashboard",
                                      ping: "_ping"})

epamotron = Repo.insert!(%Application{name: "epamotron",
                                      repo: "pbm/epamotron",
                                      ping: "_ping"})

Repo.insert!(%Application{name: "eligibility",
                                        repo: "pbm/eligibility_gateway",
                                        ping: "_ping"})

epa_gateway = Repo.insert!(%Application{name: "epa_gateway",
                                        repo: "pbm/epa_gateway",
                                        ping: "_ping"})

Repo.insert!(%Application{name: "pbmproxy",
                                     repo: "pbm/pbmproxy",
                                     ping: "_ping"})

Repo.insert!(%Application{name: "fake-plan-payer",
                                            repo: "pbm/fake-plan-payer",
                                            ping: "_ping"})

Repo.insert!(%Application{name: "formbuilder",
                                        repo: "pbm/formbuilder",
                                        ping: "_ping"})

Repo.insert!(%Application{name: "pa-starter",
                                       repo: "pbm/pa-starter",
                                       ping: "_ping"})

Repo.insert!(%Application{name: "pdfmotron",
                                      repo: "pbm/pdfmotron",
                                      ping: "_ping"})

Repo.insert!(%Application{name: "renewals-api",
                                         repo: "pbm/renewals-api",
                                         ping: "_ping"})

Repo.insert!(%Application{name: "request-updater",
                                            repo: "pbm/request-updater",
                                            ping: "_ping"})

# reservations
Repo.insert!(Reservation.changeset(%Reservation{}, %{user_id: gopal.id,
                          reserved_at: Ecto.DateTime.utc,
                          application_id: epamotron.id,
                          team_id: epa_team.id,
                          environment_id: pbm1.id}))

Repo.insert!(Reservation.changeset(%Reservation{}, %{user_id: wade.id,
                          reserved_at: Ecto.DateTime.utc,
                          application_id: admin.id,
                          team_id: epa_team.id,
                          environment_id: pbm1.id}))

Repo.insert!(Reservation.changeset(%Reservation{}, %{user_id: gopal.id,
                          reserved_at: Ecto.DateTime.utc,
                          application_id: epa_gateway.id,
                          team_id: epa_team.id,
                          environment_id: epa1.id}))

Repo.insert!(Reservation.changeset(%Reservation{}, %{user_id: chris.id,
                          reserved_at: Ecto.DateTime.utc,
                          application_id: epamotron.id,
                          team_id: epa_team.id,
                          environment_id: epa2.id}))
