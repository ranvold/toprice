import { Controller } from '@hotwired/stimulus'

function setToSessionStorage(nameTag) {
  let ids = [];

  let checkboxesIds = [];

  for (const div of document.getElementsByTagName(nameTag)[0].children) {
    if (div.children[0].checked) {
      checkboxesIds.push(div.children[0].id) 
      ids.push(div.children[0].id.split('-')[0]) 
    }
  }
  sessionStorage.setItem(nameTag + 'CheckboxesIds', JSON.stringify(checkboxesIds))
  sessionStorage.setItem(nameTag, JSON.stringify(ids))

  ids = []
  checkboxesIds = [];
}

function resetCheckboxes(nameTag) {
  for (const div of document.getElementsByTagName(nameTag)[0].children) {
    div.children[0].checked = false
  }
}

function hideFilterBar() {
  const filterbar = document.getElementById('filterbar')

  if (filterbar.classList.contains('flex-col')) {
    filterbar.classList.remove('flex-col')
    filterbar.classList.add('hidden')
  }
}

// Connects to data-controller='products--query'
export default class extends Controller {
  connect() {
    if (sessionStorage.getItem('companiesCheckboxesIds') !== null) {
      const companiesCheckboxesIds = JSON.parse(sessionStorage.getItem('companiesCheckboxesIds'))
  
      for (const id of companiesCheckboxesIds) {
        document.getElementById(id).checked = true
      }
    }
    if (sessionStorage.getItem('categoriesCheckboxesIds') !== null) {
      const categoriesCheckboxesIds = JSON.parse(sessionStorage.getItem('categoriesCheckboxesIds'))
  
      for (const id of categoriesCheckboxesIds) {
        document.getElementById(id).checked = true
      }
    }
  }

  apply() {
    setToSessionStorage('companies')
    setToSessionStorage('categories')

    let name = document.getElementById('search').value

    const companies = JSON.parse(sessionStorage.getItem('companies'))
    const categories = JSON.parse(sessionStorage.getItem('categories'))

    fetch(`/products/query?companies=${companies}&categories=${categories}&name=${name}`, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html'
      },
      credentials: 'same-origin'
    })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html))
    .catch(error => console.log(error))

    hideFilterBar()
  }

  clear() {
    sessionStorage.clear()
    resetCheckboxes('companies')
    resetCheckboxes('categories')

    hideFilterBar()
  }
}
