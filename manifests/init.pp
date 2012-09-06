class glance {

  user { 'glance':
    groups => $ssl_group,
  }
  
}

