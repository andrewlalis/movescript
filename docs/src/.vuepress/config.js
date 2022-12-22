const { description } = require('../../package')

module.exports = {
  /**
   * Ref：https://v1.vuepress.vuejs.org/config/#title
   */
  title: 'Movescript Docs',
  /**
   * Ref：https://v1.vuepress.vuejs.org/config/#description
   */
  description: description,

  base: '/movescript/',

  /**
   * Extra tags to be injected to the page HTML `<head>`
   *
   * ref：https://v1.vuepress.vuejs.org/config/#head
   */
  head: [
    ['meta', { name: 'theme-color', content: '#de9502' }],
    ['meta', { name: 'apple-mobile-web-app-capable', content: 'yes' }],
    ['meta', { name: 'apple-mobile-web-app-status-bar-style', content: 'black' }]
  ],

  /**
   * Theme configuration, here is the default theme configuration for VuePress.
   *
   * ref：https://v1.vuepress.vuejs.org/theme/default-theme-config.html
   */
  themeConfig: {
    repo: '',
    editLinks: false,
    docsDir: '',
    editLinkText: '',
    lastUpdated: false,
    nav: [
      {
        text: 'Movescript',
        link: '/guide/movescript/',
      },
      {
        text: 'Itemscript',
        link: '/guide/itemscript/'
      },
      {
        text: 'GitHub',
        link: 'https://github.com/andrewlalis/movescript'
      }
    ],
    sidebar: {
      '/guide/movescript/': [
        {
          title: 'Movescript Module',
          collapsable: false,
          children: [
            '',
            'spec',
            'settings',
            'reference'
          ]
        }
      ],
      '/guide/itemscript/': [
        {
          title: 'Itemscript Module',
          collapsable: false,
          children: [
            '',
            'filters',
            'reference'
          ]
        }
      ]
    }
  },

  /**
   * Apply plugins，ref：https://v1.vuepress.vuejs.org/zh/plugin/
   */
  plugins: [
    '@vuepress/plugin-back-to-top',
    '@vuepress/plugin-medium-zoom',
    ['vuepress-plugin-code-copy', {
      backgroundTransition: false,
      staticIcon: false,
      color: '#de9502',
      successText: 'Copied to clipboard.'
    }]
  ]
}
