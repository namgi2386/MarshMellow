package com.gbh.gbh_mm.notification.controller;


import com.gbh.gbh_mm.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;


@RestController
@RequiredArgsConstructor
@RequestMapping("/mm/notification")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping("/{userPk}")
    public List<Object> getNotifications(@PathVariable("userPk") String userPk) {
        return notificationService.getNotifications(userPk);
    }
}
