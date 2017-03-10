// client-side database for Argonaut
// not sure if there is a better pattern than this
export class ArgonautDatabase {
  constructor() {
    this.reservations = [];
    this.applications = [];
    this.environments = [];
  }

  getReservation(appId, envId) {
    return this.reservations.find(r => r.application.id == appId && r.environment.id == envId);
  }

  setReservation(reservation) {
    this.reservations.push(reservation);
  }

  deleteReservation(appId, envId) {
    const reservation = this.reservations.find(r => r.application.id == appId && r.environment.id == envId);
    if(reservation) {
      const index = this.reservations.indexOf(reservation);
      if(index > -1) this.reservations.splice(index, 1);
    }
  }
}

