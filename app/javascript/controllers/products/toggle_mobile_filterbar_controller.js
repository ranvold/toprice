import { Controller } from '@hotwired/stimulus'

// Connects to data-controller='products--toggle-mobile-filterbar'
export default class extends Controller {
  toggle(){
    const filterbar = document.getElementById('filterbar')

    if (filterbar.classList.contains('flex-col')) {
      filterbar.classList.remove('flex-col')
      filterbar.classList.add('hidden')
    } else {
      filterbar.classList.remove('hidden')
      filterbar.classList.add('flex-col')
    }
  }
}
