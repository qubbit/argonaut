alias Argonaut.{Application, Environment, User, Reservation, Repo}

# testing environments
pbm1  = Repo.insert!(%Environment{name: "pbm1"})
epa1  = Repo.insert!(%Environment{name: "epa1"})
epa2  = Repo.insert!(%Environment{name: "epa2"})
perf3 = Repo.insert!(%Environment{name: "perf3"})

# apps
admin = Repo.insert!(%Application{name: "admin",
                                  repo: "pbm/autobahn",
                                  ping: "_ping"})

dashboard = Repo.insert!(%Application{name: "dashboard",
                                      repo: "pbm/dashboard",
                                      ping: "_ping"})

epamotron = Repo.insert!(%Application{name: "epamotron",
                                      repo: "pbm/epamotron",
                                      ping: "_ping"})

eligibility = Repo.insert!(%Application{name: "eligibility",
                                        repo: "pbm/eligibility_gateway",
                                        ping: "_ping"})

epa_gateway = Repo.insert!(%Application{name: "epa_gateway",
                                        repo: "pbm/epa_gateway",
                                        ping: "_ping"})

pbmproxy = Repo.insert!(%Application{name: "pbmproxy",
                                     repo: "pbm/pbmproxy",
                                     ping: "_ping"})

fake_plan_payer = Repo.insert!(%Application{name: "fake-plan-payer",
                                            repo: "pbm/fake-plan-payer",
                                            ping: "_ping"})

formbuilder = Repo.insert!(%Application{name: "formbuilder",
                                        repo: "pbm/formbuilder",
                                        ping: "_ping"})

pa_starter = Repo.insert!(%Application{name: "pa-starter",
                                       repo: "pbm/pa-starter",
                                       ping: "_ping"})

pdfmotron = Repo.insert!(%Application{name: "pdfmotron",
                                      repo: "pbm/pdfmotron",
                                      ping: "_ping"})

renewals_api = Repo.insert!(%Application{name: "renewals-api",
                                         repo: "pbm/renewals-api",
                                         ping: "_ping"})

request_updater = Repo.insert!(%Application{name: "request-updater",
                                            repo: "pbm/request-updater",
                                            ping: "_ping"})

# users
gopal = Repo.insert!(User.registration_changeset(%User{}, %{username: "gadhikari", password: "abcd1234", is_admin: true, time_zone: "America/New_York"}))
wade = Repo.insert!(User.registration_changeset(%User{}, %{username: "wjohnson", password: "changeme", time_zone: "American/Chicago"}))
chris = Repo.insert!(User.registration_changeset(%User{}, %{username: "cdoggett", password: "changeme", time_zone: "America/Chicago"}))

# reservations

Repo.insert!(Reservation.changeset(%Reservation{}, %{user_id: gopal.id,
                          reserved_at: Ecto.DateTime.utc,
                          application_id: epamotron.id,
                          environment_id: pbm1.id}))

Repo.insert!(Reservation.changeset(%Reservation{}, %{user_id: wade.id,
                          reserved_at: Ecto.DateTime.utc,
                          application_id: admin.id,
                          environment_id: pbm1.id}))

Repo.insert!(Reservation.changeset(%Reservation{}, %{user_id: gopal.id,
                          reserved_at: Ecto.DateTime.utc,
                          application_id: epa_gateway.id,
                          environment_id: epa1.id}))

Repo.insert!(Reservation.changeset(%Reservation{}, %{user_id: chris.id,
                          reserved_at: Ecto.DateTime.utc,
                          application_id: epamotron.id,
                          environment_id: epa2.id}))

