export type Team = {
  id: number,
  name: string,
}

export type User = {
  username: string,
  email: string,
}


export type Application = {
  id: number,
  name: string,
}


export type Environment = {
  id: number,
  name: string,
}

export type Reservation = {
  id: number,
  reserved_at: string,
  user: User,
  team: Team,
  application: Application,
  environment: Environment,
  humanized_time: string
}

export type Paginatinon = {
  total_pages: number,
  total_entries: number,
  page_size: number,
  page_number: number,
}
