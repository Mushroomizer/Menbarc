double getNozzleFlowPerMinuteAt3Bar(String nozzle) {
  double constant = 0.0;
  switch (nozzle) {
    case "01":
      constant = 0.39;
      break;
    case "02":
      constant = 0.79;
      break;
    case "03":
      constant = 1.2;
      break;
    case "04":
      constant = 1.6;
      break;
    case "05":
      constant = 2;
      break;
    case "06":
      constant = 2.4;
      break;
    case "07":
      constant = 2.8;
      break;
    case "08":
      constant = 3.2;
      break;
    case "09":
      constant = 3.6;
      break;
    case "10":
      constant = 3.9;
      break;
    case "15":
      constant = 5.9;
      break;
    case "20":
      constant = 7.9;
      break;
    case "25":
      constant = 9.9;
      break;
    case "30":
      constant = 11.8;
      break;
    case "40":
      constant = 15.8;
      break;
    case "50":
      constant = 19.7;
      break;
    case "60":
      constant = 24;
      break;
    case "70":
      constant = 28;
      break;
    default:
      constant = 0;
  }
  return constant;
}
