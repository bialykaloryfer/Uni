import pygame
import sys
import math

pygame.init()
screen = pygame.display.set_mode((900, 900))
pygame.display.set_caption("Rysownik Krzywych Beziera")

black = (0, 0, 0)
white = (255, 255, 255)
orange = (255, 165, 0)

def alfabet(letter):
    if letter == "a":
        return [[(337, 143), (443, 358), (469, 386)],
                [(469, 386), (515, 409), (484, 439), (445, 437)],
                [(445, 437), (341, 436)],
                [(341, 436), (276, 435), (302, 391), (328, 382)],
                [(328, 382), (339, 366), (331, 348), (269, 357), (230, 359)],
                [(230, 359), (190, 362), (210, 391), (231, 392)],
                [(231, 392), (258, 404), (208, 454), (210, 438), (150, 449), (113, 426)],
                [(113, 426), (85, 401), (125, 385)],
                [(225, 181)],
                [(125, 385), (154, 324), (201, 268), (229, 190)],
                [(312, 331), (339, 328), (322, 263), (268, 245)],
                [(227, 193), (195, 117), (141, 220), (245, 31), (337, 144)],
                [(268, 247), (221, 265), (223, 327)],
                [(223, 327), (312, 329)]]

    if letter == "b":
        return [[(143, 462), (348, 461)],
                [(346, 461), (484, 459), (611, 482), (377, 293)],
                [(374, 291), (375, 208), (597, 307), (375, 108)],
                [(374, 108), (119, 108)],
                [(119, 108), (92, 117), (114, 150), (143, 167)],
                [(143, 167), (142, 389)],
                [(142, 389), (60, 472), (98, 464), (145, 462)],
                [(336, 285)],
                [(283, 412), (419, 427), (383, 294), (201, 287), (232, 318), (282, 411)],
                [(260, 245), (182, 143), (242, 115), (324, 174), (440, 253), (261, 246)]]

    if letter == "c":
        return [[(217, 109), (15, 260), (121, 553), (365, 462), (409, 430)],
                [(409, 430), (501, 486), (500, 252), (480, 312), (454, 322), (403, 360)],
                [(403, 360), (256, 454), (201, 299)],
                [(201, 298), (173, 123), (406, 136), (393, 208)],
                [(393, 208), (396, 270), (442, 249), (496, 223)],
                [(496, 101)],
                [(496, 223), (505, 106), (412, 119)],
                [(412, 119), (317, 68), (218, 109)]]

    if letter == "d":
        return [[(133, 454), (342, 460)],
                [(383, 118)],
                [(342, 460), (495, 439), (556, 273), (477, 149), (383, 118)],
                [(104, 131), (78, 191), (122, 239), (142, 183)],
                [(142, 183), (144, 388)],
                [(144, 388), (88, 345), (76, 424), (131, 454)],
                [(227, 202), (227, 378)],
                [(226, 377), (306, 405), (389, 435), (555, 229), (334, 127), (270, 158), (229, 201)],
                [(383, 118), (224, 76), (105, 130)]]

    if letter == "e":
        return [[(127, 109), (304, 59), (427, 100)],
                [(427, 100), (504, 135), (458, 264), (422, 169)],
                [(419, 166), (376, 151), (240, 104), (285, 230)],
                [(285, 230), (289, 242), (322, 275), (329, 210)],
                [(329, 211), (355, 169), (393, 209), (360, 343)],
                [(362, 345), (361, 182), (266, 382), (276, 216), (234, 330), (305, 388)],
                [(305, 386), (350, 415), (403, 407), (425, 356)],
                [(424, 358), (453, 302), (472, 295), (474, 430), (457, 466)],
                [(457, 466), (136, 466)],
                [(136, 466), (80, 344), (157, 407)],
                [(157, 407), (200, 289), (164, 183)],
                [(164, 183), (160, 151), (129, 295), (96, 198), (127, 108)]]

    if letter == "f":
        return [[(79, 107), (439, 110)],
                [(439, 110), (493, 127), (468, 146), (465, 363), (408, 201)],
                [(408, 201)],
                [(408, 201), (399, 184), (264, 149), (287, 258)],
                [(286, 257), (305, 289), (328, 274), (337, 246)],
                [(322, 357)],
                [(337, 248), (344, 186), (449, 216), (320, 507), (366, 393), (322, 357)],
                [(322, 357), (289, 326), (277, 461), (166, 449), (319, 463)],
                [(322, 462), (349, 508), (287, 514)],
                [(286, 513), (127, 512)],
                [(127, 512), (93, 500), (24, 534), (138, 442)],
                [(138, 442), (175, 416), (207, 281), (161, 199)],
                [(160, 195), (108, 152), (69, 427), (79, 110)]]

    if letter == "g":
        return [[(293, 110), (65, 106), (116, 348), (54, 485), (142, 502), (384, 447)],
                [(384, 447), (438, 432), (462, 231), (416, 412), (718, 456), (497, 211), (392, 365), (132, 225),
                 (227, 328), (350, 314), (332, 365)],
                [(440, 147)],
                [(332, 365), (307, 418), (55, 472), (169, 160), (202, 105), (358, 146), (399, 155), (347, 251),
                 (432, 284), (502, 277), (422, 158)],
                [(422, 159), (356, 15), (391, 139), (292, 110)]]

    if letter == "h":
        return [[(450, 377), (455, 178)],
                [(454, 178), (451, 143), (698, 91), (471, 96), (316, 114), (282, 58), (236, 145), (362, 131),
                 (387, 165), (360, 214)],
                [(362, 209), (338, 253), (241, 241), (254, 188), (262, 168)],
                [(261, 169), (325, 104), (282, 90), (196, 88), (102, 113)],
                [(143, 177)],
                [(100, 114), (95, 259), (143, 177)],
                [(143, 177), (142, 365)],
                [(142, 365), (85, 443), (21, 460), (129, 439), (246, 440)],
                [(266, 385), (298, 411), (244, 439)],
                [(267, 385), (251, 360), (223, 312), (255, 307), (322, 281), (392, 319), (430, 335), (318, 392),
                 (345, 390)],
                [(342, 390), (306, 416), (335, 428), (208, 460), (467, 446)],
                [(468, 448), (542, 312), (450, 379)]]

    if letter == "i":
        return [[(373, 385), (371, 202)],
                [(371, 203), (395, 157), (406, 153), (470, 143), (612, 104), (436, 110)],
                [(438, 108), (151, 111)],
                [(151, 111), (51, 104), (187, 172), (228, 130), (233, 203)],
                [(233, 202), (235, 372)],
                [(235, 372), (250, 437), (185, 411), (141, 446), (41, 482), (151, 478)],
                [(148, 478), (427, 479)],
                [(427, 479), (612, 487), (455, 435), (369, 443), (373, 385)]]

    if letter == "j":
        return [[(99, 327), (138, 462), (125, 542), (465, 578), (447, 395)],
                [(446, 191)],
                [(447, 395), (446, 191)],
                [(446, 191), (439, 156), (482, 138), (611, 124), (473, 111)],
                [(473, 111), (454, 109), (405, 109), (261, 99)],
                [(263, 99), (131, 97), (180, 106), (270, 145)],
                [(267, 145), (318, 169), (331, 207)],
                [(331, 207), (322, 370)],
                [(322, 370), (340, 435), (276, 485), (177, 430), (246, 356)],
                [(246, 356), (191, 328), (132, 308), (70, 265), (99, 326)]]


class Button:
    def __init__(self, x, y, width, height, inactive_color, active_color, text, font, action=None):
        self.rect = pygame.Rect(x, y, width, height)
        self.text = text
        self.font = font
        self.inactive_color = inactive_color
        self.active_color = active_color
        self.action = action
        self.state = False

    def draw(self):
        mouse_pos = pygame.mouse.get_pos()
        on_button = self.rect.collidepoint(mouse_pos)

        if on_button:
            pygame.draw.rect(screen, self.active_color, self.rect)
        else:
            pygame.draw.rect(screen, self.inactive_color, self.rect)

        text_surface = self.font.render(self.text, True, black)
        text_rect = text_surface.get_rect(center=self.rect.center)
        screen.blit(text_surface, text_rect)

    def click(self):
        mouse_pos = pygame.mouse.get_pos()
        click = pygame.mouse.get_pressed()

        on_button = self.rect.collidepoint(mouse_pos)

        if on_button and click[0] == 1:
            self.action()
            self.state = not self.state
            return True
        return False


def draw_bezier_curve(points):
    for t in range(0, 1000, 1):
        t /= 1000.0
        x, y = bezier_curve(t, points)
        pygame.draw.circle(screen, orange, (int(x), int(y)), 1)


def newton_symbol(n, i):
    return math.factorial(n) / (math.factorial(i) * math.factorial(n - i))


def bezier_curve(t, points):
    n = len(points) - 1
    x, y = 0, 0
    for i, (px, py) in enumerate(points):
        f = newton_symbol(n, i) * (t ** i) * ((1 - t) ** (n - i))
        x += f * px
        y += f * py
    return x, y


def program():
    points = []
    active_points = []
    buttons = []
    button_font = pygame.font.Font(None, 25)

    def draw():
        nonlocal buttons

        screen.fill(white)
        for button in buttons:
            button.draw()

        for point in [point for curve_points in points for point in curve_points] + active_points:
            pygame.draw.circle(screen, black, point, 4)

        for curve_points in points + [active_points]:
            if len(curve_points) > 1:
                draw_bezier_curve(curve_points)
        pygame.display.flip()

    def edit_curve():
        nonlocal active_points
        nonlocal points
        on = True
        if active_points:
            points.append(active_points)
            active_points = []

        while on:
            mouse_pos = pygame.mouse.get_pos()
            pygame.event.get()

            if pygame.mouse.get_pressed()[0]:
                for index, curve in enumerate(points):
                    for index_p, point in enumerate(curve):
                        if math.dist(point, mouse_pos) < 20:
                            active_points = curve[:]
                            if points[index]:
                                points.pop(index)
                            if index_p < len(curve) / 2:
                                active_points.reverse()
                            on = not on
                            break

            if pygame.mouse.get_pressed()[2]:
                return

    def cancel_curve():
        nonlocal active_points
        nonlocal points
        on = True

        if active_points:
            points.append(active_points)
            active_points = []

        while on:
            mouse_pos = pygame.mouse.get_pos()
            pygame.event.get()
            if pygame.mouse.get_pressed()[0]:
                for index, curve in enumerate(points):
                    for point in curve:
                        if math.dist(point, mouse_pos) < 20:
                            points.pop(index)
                            on = not on
            if pygame.mouse.get_pressed()[2]:
                return

    def start_new():
        nonlocal points
        nonlocal active_points

        if active_points:
            points.append(active_points)
            active_points = [active_points[-1]]

    def cancel_last():
        nonlocal points
        nonlocal active_points

        if active_points:
            active_points.pop()
        elif points:
            points[-1].pop()

        if points and not points[-1]:
            points.pop()

    def move_point():
        nonlocal points
        nonlocal active_points
        chosen = False
        chosen_point_index = ()
        if active_points:
            points.append(active_points)
            active_points = []

        while pygame.mouse.get_pressed()[2]:
            mouse_pos = pygame.mouse.get_pos()
            if not chosen:
                for index_p, curve in enumerate(points):
                    for index_c, point in enumerate(curve):
                        if math.dist(point, mouse_pos) < 20:
                            chosen_point_index = (index_p, index_c)
                            chosen = True
            else:
                points[chosen_point_index[0]][chosen_point_index[1]] = mouse_pos
            draw()
            pygame.event.get()

        return

    def save_curve():
        nonlocal points
        nonlocal active_points

        if active_points:
            points.append(active_points)
            active_points = []

    def cancel_point():
        nonlocal points
        nonlocal active_points
        on = True

        if active_points:
            points.append(active_points)
            active_points = []

        while on:
            mouse_pos = pygame.mouse.get_pos()
            for curve in points:
                for index, point in enumerate(curve):
                    if math.dist(point, mouse_pos) < 10 and pygame.mouse.get_pressed()[0]:
                        curve.pop(index)
            if pygame.mouse.get_pressed()[2]:
                on = not on
            draw()
            pygame.event.get()

        return

    button_save = Button(0, 0, 150, 60, "gray67", "gray62", "Zapisz", button_font, action=save_curve)
    button_edit_curve = Button(150, 0, 150, 60, "gray67", "gray62", "Edytuj krzywą", button_font, action=edit_curve)
    button_cancel_last_added = Button(300, 0, 150, 60, "gray67", "gray62", "Wstecz", button_font, action=cancel_last)
    button_cancel_curve = Button(450, 0, 150, 60, "gray67", "gray62", "Usuń Krzywą", button_font, action=cancel_curve)
    button_cancel_point = Button(600, 0, 150, 60, "gray67", "gray62", "Usuń punkt", button_font, action=cancel_point)
    button_start_new = Button(750, 0, 150, 60, "gray67", "gray62", "Kąt", button_font, action=start_new)
    buttons.extend([button_edit_curve, button_start_new, button_cancel_curve, button_cancel_last_added, button_save,
                    button_cancel_point])

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            elif event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1:
                    if button_edit_curve.click():
                        continue
                    elif button_cancel_curve.click():
                        continue
                    elif button_start_new.click():
                        continue
                    elif button_cancel_last_added.click():
                        continue
                    elif button_save.click():
                        continue
                    elif button_cancel_point.click():
                        continue
                    else:
                        active_points.append(event.pos)
                elif event.button == 3:
                    move_point()
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_RETURN:
                    for element in points:
                        print(element)
                elif event.key == pygame.K_a:
                    points = alfabet("a")
                    active_points = []
                elif event.key == pygame.K_b:
                    points = alfabet("b")
                    active_points = []
                elif event.key == pygame.K_c:
                    points = alfabet("c")
                    active_points = []
                elif event.key == pygame.K_d:
                    points = alfabet("d")
                    active_points = []
                elif event.key == pygame.K_e:
                    points = alfabet("e")
                    active_points = []
                elif event.key == pygame.K_f:
                    points = alfabet("f")
                    active_points = []
                elif event.key == pygame.K_g:
                    points = alfabet("g")
                    active_points = []
                elif event.key == pygame.K_h:
                    points = alfabet("h")
                    active_points = []
                elif event.key == pygame.K_i:
                    points = alfabet("i")
                    active_points = []
                elif event.key == pygame.K_j:
                    points = alfabet("j")
                    active_points = []
        draw()


program()
