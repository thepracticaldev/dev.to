import Chart from 'chart.js';
import { Object } from 'es6-shim';

const reactionsCanvas = document.getElementById('reactionsChart');
const commentsCanvas = document.getElementById('commentsChart');

const padDate = month => String(`00${month}`).slice(-2);

const oneWeekAgo = new Date();
oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

fetch(
  `/api/analytics/historical?start=${oneWeekAgo.getFullYear()}-${padDate(
    oneWeekAgo.getMonth() + 1,
  )}-${padDate(oneWeekAgo.getDate())}`,
)
  .then(data => data.json())
  .then(data => {
    const labels = Object.keys(data);
    const parsedData = Object.entries(data).map(date => date[1]);
    const comments = parsedData.map(date => date.comments.total);
    const reactions = parsedData.map(date => date.reactions.total);
    const likes = parsedData.map(date => date.reactions.like);
    const readingList = parsedData.map(date => date.reactions.readinglist);
    const unicorns = parsedData.map(date => date.reactions.unicorn);

    const reactionsChart = new Chart(reactionsCanvas, {
      type: 'line',
      data: {
        labels,
        datasets: [
          {
            label: 'Total',
            data: reactions,
            // data: [5, 10, 15, 17, 25, 23],
            fill: false,
            borderColor: 'rgb(75, 192, 192)',
            lineTension: 0.1,
          },
          {
            label: 'Likes',
            data: likes,
            // data: [2, 5, 10, 10, 15, 13],
            fill: false,
            borderColor: 'rgb(229, 100, 100)',
            lineTension: 0.1,
          },
          {
            label: 'Unicorns',
            data: unicorns,
            // data: [1, 2, 2, 4, 5, 3],
            fill: false,
            borderColor: 'rgb(157, 57, 233)',
            lineTension: 0.1,
          },
          {
            label: 'Bookmarks',
            data: readingList,
            // data: [2, 3, 3, 3, 5, 7],
            fill: false,
            borderColor: 'rgb(10, 133, 255)',
            lineTension: 0.1,
          },
        ],
      },
      options: {
        legend: {
          position: 'bottom',
        },
        responsive: true,
        title: {
          display: true,
          text: 'Reactions this Week',
        },
        scales: {
          yAxes: [
            {
              ticks: {
                suggestedMin: 0,
                precision: 0,
              },
            },
          ],
        },
      },
    });

    const commentsChart = new Chart(commentsCanvas, {
      type: 'line',
      data: {
        labels,
        datasets: [
          {
            label: 'Comments',
            data: comments,
            fill: false,
            borderColor: 'rgb(75, 192, 192)',
            lineTension: 0.1,
          },
        ],
      },
      options: {
        legend: {
          position: 'bottom',
        },
        responsive: true,
        title: {
          display: true,
          text: 'Comments this week',
        },
        scales: {
          yAxes: [
            {
              ticks: {
                suggestedMin: 0,
                precision: 0,
              },
            },
          ],
        },
      },
    });
  });
