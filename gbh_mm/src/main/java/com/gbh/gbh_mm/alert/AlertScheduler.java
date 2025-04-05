package com.gbh.gbh_mm.alert;

import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Component
@AllArgsConstructor
public class AlertScheduler {
    private AlertService alertService;
    private UserRepository userRepository;

    /* 매일 10시 */
    @Scheduled(cron = "0 0 10 * * ?")
    public void sendSalaryNotification() {
        LocalDate todayDate = LocalDate.now();
        int today = todayDate.getDayOfMonth();
        YearMonth currentMonth = YearMonth.from(todayDate);
        int lastDayOfMonth = currentMonth.lengthOfMonth();

        List<User> userList = userRepository.findBySalaryDate(today);

        for (User user : userList) {
            int userSalaryDate = user.getSalaryDate();

            if (today == userSalaryDate) {
                sendNotification(user);
            } else if (userSalaryDate > lastDayOfMonth && today == lastDayOfMonth) {
                sendNotification(user);
            }
        }
    }

    private void sendNotification(User user) {
        if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
            String title = "월급 알림";
            String body = "오늘은 월급날이에요! 예산을 짜드릴게요 :)";
            alertService.sendNotification(user.getFcmToken(), title, body);
        }
    }

    // 오늘의 예산 알림
    /* 매일 9시 */
    @Scheduled(cron = "0 0 9 * * ?")
    public void sendBudgetNotification() throws InterruptedException, ExecutionException {

        List<User> userList = userRepository.findAll();

        for (User user : userList) {
            if (user.getFcmToken() != null) {
                alertService.sendBudgetNotification(user);
            }
        }
    }
}
