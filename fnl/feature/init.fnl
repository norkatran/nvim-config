(let [features [:browser :fish :term :workbook :docker :jira]]
  (each [_ feature (ipairs features)] (require (.. :feature. feature))))
