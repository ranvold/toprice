import { Controller } from '@hotwired/stimulus'

const CHECKBOXES_NAMES = ['companies', 'categories']
const COMPANIES_CHECKBOXES_IN_STORAGE = 'companiesCheckboxesIds'
const CATEGORIES_CHECKBOXES_IN_STORAGE = 'categoriesCheckboxesIds'

function setFilterToSessionStorage() {
  for (const checkboxes of CHECKBOXES_NAMES) {
    let checkboxesValues = [];
  
    let checkboxesIds = [];
  
    for (const div of document.getElementById(checkboxes).children) {
      if (div.children[0].checked) {
        checkboxesIds.push((div.children[0].id).toString()) 
        checkboxesValues.push(parseInt(div.children[0].value)) 
      }
    }
    sessionStorage.setItem(checkboxes, JSON.stringify(checkboxesValues))
    
    if (checkboxes === 'companies') {
      sessionStorage.setItem(COMPANIES_CHECKBOXES_IN_STORAGE, JSON.stringify(checkboxesIds))
    } else {
      sessionStorage.setItem(CATEGORIES_CHECKBOXES_IN_STORAGE, JSON.stringify(checkboxesIds))
    }
  }
}

function resetFilter() {
  if (document.getElementById('filter') !== null) {
    for (const checkboxes of CHECKBOXES_NAMES) {
      for (const div of document.getElementById(checkboxes).children) {
        div.children[0].checked = false
      }
    }
  }
}

function refreshFilter() {
  if (document.getElementById('filter') !== null) {
    if (sessionStorage.getItem(COMPANIES_CHECKBOXES_IN_STORAGE) !== null) {
      const companiesCheckboxesIds = JSON.parse(sessionStorage.getItem(COMPANIES_CHECKBOXES_IN_STORAGE))

      for (const id of companiesCheckboxesIds) {
        document.getElementById(id).checked = true
      }
    }
    if (sessionStorage.getItem(CATEGORIES_CHECKBOXES_IN_STORAGE) !== null) {
      const categoriesCheckboxesIds = JSON.parse(sessionStorage.getItem(CATEGORIES_CHECKBOXES_IN_STORAGE))
  
      for (const id of categoriesCheckboxesIds) {
        document.getElementById(id).checked = true
      }
    }
  }
}

// Connects to data-controller='products--search'
export default class extends Controller {
  connect() {
    refreshFilter()
  }

  apply() {
    const name = JSON.stringify((document.getElementById('search_field').value).toString())

    if (document.getElementById('filter') !== null) {
      setFilterToSessionStorage()

      const companies = sessionStorage.getItem(CHECKBOXES_NAMES[0])
      const categories = sessionStorage.getItem(CHECKBOXES_NAMES[1])

      const params = `companies=${companies}&categories=${categories}&name=${name}`

      fetch(`/products/search?${params}`, {
        headers: {'Accept': 'text/vnd.turbo-stream.html'}})
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
      .then(this.hideFilter())
      .catch(error => console.log(error))
    } else {
      this.clear()

      const url = `/products/search?name=${name}`

      fetch(url)
      .then(response => response.text())
      .then(html => {
        document.open()
        document.write(html)
        document.close()
        history.pushState({}, '', url)
      })
      .catch(error => console.error(error))
    }
  }

  toggleFilter() {
    const filter = document.getElementById('filter')

    if (filter.classList.contains('sticky')) {
      filter.classList.remove('sticky')
      filter.classList.add('hidden')
    } else {
      filter.classList.remove('hidden')
      filter.classList.add('sticky')
    }
  }

  hideFilter() {
    if (document.getElementById('filter') !== null) {
      const filter = document.getElementById('filter')
    
      filter.classList.remove('sticky')
      filter.classList.add('hidden')
      window.scrollTo(0, 0)
    }
  }

  clear() {
    sessionStorage.clear()
    resetFilter()
    this.hideFilter()
  }
}
