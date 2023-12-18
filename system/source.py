import pandas as pd
import warnings
from glob import glob
import os
from datetime import datetime, timedelta
warnings.filterwarnings("ignore")


# Columns per zone
sala = {
    "ZONE": "SALA",
    "convection": {
        "SALA_PARIN_01S:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PARIN_00E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PORTAIN_0_00E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PARIN_01D:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PORTAIN_0_01D:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PARIN_02D:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PORTAIN_0_02D:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PAREX_00I:Surface Inside Face Convection Heat Gain Rate": "convection?south_extwalls",
        "SALA_PAREX_00S:Surface Inside Face Convection Heat Gain Rate": "convection?north_extwalls",
        "SALA_PORTAEX_0_00S:Surface Inside Face Convection Heat Gain Rate": "convection?north_extwalls",
        "SALA_PAREX_01E:Surface Inside Face Convection Heat Gain Rate": "convection?west_extwalls",
        "SALA_PAREX_00D:Surface Inside Face Convection Heat Gain Rate": "convection?east_extwalls",
        "SALA_PORTAEX_0_00D:Surface Inside Face Convection Heat Gain Rate": "convection?east_extwalls",
        "SALA_PISO:Surface Inside Face Convection Heat Gain Rate": "convection?none_floor",
        "SALA_COB_1:Surface Inside Face Convection Heat Gain Rate": "convection?none_roof",
        "SALA_COB_0:Surface Inside Face Convection Heat Gain Rate": "convection?none_roof",
        "SALA_JAN_0_00I:Surface Inside Face Convection Heat Gain Rate": "convection?south_windows",
        "SALA_JAN_0_01E:Surface Inside Face Convection Heat Gain Rate": "convection?west_windows",
        "SALA_JAN_0_00I:Surface Window Inside Face Frame and Divider Zone Heat Gain Rate": "convection?south_frame",
        "SALA_JAN_0_01E:Surface Window Inside Face Frame and Divider Zone Heat Gain Rate": "convection?west_frame",
        "SALA:Zone Total Internal Convective Heating Rate": "convection?internal_gains",
        "SALA:AFN Zone Ventilation Sensible Heat Gain Rate": "convection?vn_window_gain",
        "SALA:AFN Zone Ventilation Sensible Heat Loss Rate": "convection?vn_window_loss",
        "SALA:AFN Zone Mixing Sensible Heat Gain Rate": "convection?vn_interzone_gain",
        "SALA:AFN Zone Mixing Sensible Heat Loss Rate": "convection?vn_interzone_loss",
        "SALA:Zone Air System Sensible Heating Rate": "convection?heating",
        "SALA:Zone Air System Sensible Cooling Rate": "convection?cooling"
        },
    "surface": {
        'SALA_PARIN_01S:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Convection Heat Gain Rate': 'convection?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Convection Heat Gain Rate': 'convection?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Convection Heat Gain Rate': 'convection?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Convection Heat Gain Rate': 'convection?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Convection Heat Gain Rate': 'convection?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Convection Heat Gain Rate': 'convection?east_extwalls',
        'SALA_PISO:Surface Inside Face Convection Heat Gain Rate': 'convection?none_floor',
        'SALA_COB_1:Surface Inside Face Convection Heat Gain Rate': 'convection?none_roof',
        'SALA_COB_0:Surface Inside Face Convection Heat Gain Rate': 'convection?none_roof',
        'SALA_PARIN_01S:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?east_extwalls',
        'SALA_PISO:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_floor',
        'SALA_COB_1:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_roof',
        'SALA_COB_0:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_roof',
        'SALA_PARIN_01S:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?east_extwalls',
        'SALA_PISO:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_floor',
        'SALA_COB_1:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_roof',
        'SALA_COB_0:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_roof',
        'SALA_PARIN_01S:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?east_extwalls',
        'SALA_PISO:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_floor',
        'SALA_COB_1:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_roof',
        'SALA_COB_0:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_roof',
        'SALA_PARIN_01S:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?east_extwalls',
        'SALA_PISO:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_floor',
        'SALA_COB_1:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_roof',
        'SALA_COB_0:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_roof',
        'SALA_PARIN_01S:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?east_extwalls',
        'SALA_PISO:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_floor',
        'SALA_COB_1:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_roof',
        'SALA_COB_0:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_roof'
    }
}
dorm1 = {
    "ZONE": "DORM1",
    "convection": {
        "DORM1_PARIN_00E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM1_PARIN_00S:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM1_PORTAIN_0_00E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM1_PAREX_00I:Surface Inside Face Convection Heat Gain Rate": "convection?south_extwalls",
        "DORM1_PAREX_00D:Surface Inside Face Convection Heat Gain Rate": "convection?east_extwalls",
        "DORM1_PISO:Surface Inside Face Convection Heat Gain Rate": "convection?none_floor",
        "DORM1_COB:Surface Inside Face Convection Heat Gain Rate": "convection?none_roof",
        "DORM1_JAN_0_00I:Surface Inside Face Convection Heat Gain Rate": "convection?south_windows",
        "DORM1_JAN_0_00I:Surface Window Inside Face Frame and Divider Zone Heat Gain Rate": "convection?south_frame",
        "DORM1:Zone Total Internal Convective Heating Rate": "convection?internal_gains",
        "DORM1:AFN Zone Ventilation Sensible Heat Gain Rate": "convection?vn_window_gain",
        "DORM1:AFN Zone Ventilation Sensible Heat Loss Rate": "convection?vn_window_loss",
        "DORM1:AFN Zone Mixing Sensible Heat Gain Rate": "convection?vn_interzone_gain",
        "DORM1:AFN Zone Mixing Sensible Heat Loss Rate": "convection?vn_interzone_loss",
        "DORM1:Zone Air System Sensible Heating Rate": "convection?heating",
        "DORM1:Zone Air System Sensible Cooling Rate": "convection?cooling"
        },
    "surface": {
        'DORM1_PARIN_00E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Convection Heat Gain Rate': 'convection?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Convection Heat Gain Rate': 'convection?east_extwalls',
        'DORM1_PISO:Surface Inside Face Convection Heat Gain Rate': 'convection?none_floor',
        'DORM1_COB:Surface Inside Face Convection Heat Gain Rate': 'convection?none_roof',
        'DORM1_PARIN_00E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?east_extwalls',
        'DORM1_PISO:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_floor',
        'DORM1_COB:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_roof',
        'DORM1_PARIN_00E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?east_extwalls',
        'DORM1_PISO:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_floor',
        'DORM1_COB:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_roof',
        'DORM1_PARIN_00E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?east_extwalls',
        'DORM1_PISO:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_floor',
        'DORM1_COB:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_roof',
        'DORM1_PARIN_00E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?east_extwalls',
        'DORM1_PISO:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_floor',
        'DORM1_COB:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_roof',
        'DORM1_PARIN_00E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?east_extwalls',
        'DORM1_PISO:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_floor',
        'DORM1_COB:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_roof'
    }
}
dorm2 = {
    "ZONE": "DORM2",
    "convection": {
        "DORM2_PARIN_00I:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM2_PARIN_01E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM2_PORTAIN_0_01E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM2_PAREX_00E:Surface Inside Face Convection Heat Gain Rate": "convection?west_extwalls",
        "DORM2_PAREX_00D:Surface Inside Face Convection Heat Gain Rate": "convection?east_extwalls",
        "DORM2_PAREX_00S:Surface Inside Face Convection Heat Gain Rate": "convection?north_extwalls",
        "DORM2_PISO:Surface Inside Face Convection Heat Gain Rate": "convection?none_floor",
        "DORM2_COB:Surface Inside Face Convection Heat Gain Rate": "convection?none_roof",
        "DORM2_JAN_0_00D:Surface Inside Face Convection Heat Gain Rate": "convection?east_windows",
        "DORM2_JAN_0_00D:Surface Window Inside Face Frame and Divider Zone Heat Gain Rate": "convection?east_frame",
        "DORM2:Zone Total Internal Convective Heating Rate": "convection?internal_gains",
        "DORM2:AFN Zone Ventilation Sensible Heat Gain Rate": "convection?vn_window_gain",
        "DORM2:AFN Zone Ventilation Sensible Heat Loss Rate": "convection?vn_window_loss",
        "DORM2:AFN Zone Mixing Sensible Heat Gain Rate": "convection?vn_interzone_gain",
        "DORM2:AFN Zone Mixing Sensible Heat Loss Rate": "convection?vn_interzone_loss",
        "DORM2:Zone Air System Sensible Heating Rate": "convection?heating",
        "DORM2:Zone Air System Sensible Cooling Rate": "convection?cooling"
        },
    "surface": {
        'DORM2_PARIN_00I:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Convection Heat Gain Rate': 'convection?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Convection Heat Gain Rate': 'convection?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Convection Heat Gain Rate': 'convection?north_extwalls',
        'DORM2_PISO:Surface Inside Face Convection Heat Gain Rate': 'convection?none_floor',
        'DORM2_COB:Surface Inside Face Convection Heat Gain Rate': 'convection?none_roof',
        'DORM2_PARIN_00I:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?north_extwalls',
        'DORM2_PISO:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_floor',
        'DORM2_COB:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_roof',
        'DORM2_PARIN_00I:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?north_extwalls',
        'DORM2_PISO:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_floor',
        'DORM2_COB:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_roof',
        'DORM2_PARIN_00I:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?north_extwalls',
        'DORM2_PISO:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_floor',
        'DORM2_COB:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_roof',
        'DORM2_PARIN_00I:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?north_extwalls',
        'DORM2_PISO:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_floor',
        'DORM2_COB:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_roof',
        'DORM2_PARIN_00I:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?north_extwalls',
        'DORM2_PISO:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_floor',
        'DORM2_COB:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_roof'
    }
}
all = {
    'ZONE': 'ALL ZONES',
    'Environment': 'drybulb?temp_ext'
}

wanted_list = ['Date/Time', all['Environment']]
for item in sala['convection']:
    wanted_list.append(f"{sala['ZONE']}_{sala['convection'][item]}")
for item in sala['surface']:
    wanted_list.append(f"{sala['ZONE']}_{sala['surface'][item]}")
for item in dorm1['convection']:
    wanted_list.append(f"{dorm1['ZONE']}_{dorm1['convection'][item]}")
for item in dorm1['surface']:
    wanted_list.append(f"{dorm1['ZONE']}_{dorm1['surface'][item]}")
for item in dorm2['convection']:
    wanted_list.append(f"{dorm2['ZONE']}_{dorm2['convection'][item]}")
for item in dorm2['surface']:
    wanted_list.append(f"{dorm2['ZONE']}_{dorm2['surface'][item]}")
wanted_list = list(set(wanted_list))

dont_change_list = [all['Environment']]
for item in wanted_list:
    if item.endswith('loss') or item.endswith('gains') or item.endswith('gain') or item.endswith('cooling') or item.endswith('heating'):
        dont_change_list.append(item)
dont_change_list = list(set(dont_change_list))

ref_multiply_list = ["none_intwalls", "south_extwalls", "north_extwalls", "west_extwalls", "east_extwalls", "none_floor", "none_roof", "south_windows", "west_windows", "east_windows", "east_windows", "vn_window_loss", "vn_interzone_loss", "cooling"]
multiply_list = []
for item in ref_multiply_list:
    for i in wanted_list:
        if item in i:
            multiply_list.append(i)
multiply_list = list(set(multiply_list))

items_list_for_surface = []
for ref in sala['surface']:
    items_list_for_surface.append(sala['surface'][ref].split('?')[1])
for ref in dorm1['surface']:
    items_list_for_surface.append(dorm1['surface'][ref].split('?')[1])
for ref in dorm2['surface']:
    items_list_for_surface.append(dorm2['surface'][ref].split('?')[1])
items_list_for_surface.append(all['Environment'].split('?')[1])
items_list_for_surface = list(set(items_list_for_surface))

frames_and_windows = {
    'south_windows_gain': 'south_frame_gain',
    'south_windows_loss': 'south_frame_loss',
    'west_windows_gain': 'west_frame_gain',
    'west_windows_loss': 'west_frame_loss',
    'east_windows_gain': 'east_frame_gain',
    'east_windows_loss': 'east_frame_loss'
}

# Paths
surface_output_path = r'output/surface/'
convection_output_path = r'output/convection/'
surface_input_path = r'input/surface/'
convection_input_path = r'input/convection/'
organizer_path = r'system/organizer/'


# Style
software_name = """▀█▀ █░█ █▀▀ █▀█ █▀▄▀█ ▄▀█ █░░   █▄▄ ▄▀█ █░░ ▄▀█ █▄░█ █▀▀ █▀▀   █▀▀ ▄▀█ █░░ █▀▀ █░█ █░░ ▄▀█ ▀█▀ █▀█ █▀█
░█░ █▀█ ██▄ █▀▄ █░▀░█ █▀█ █▄▄   █▄█ █▀█ █▄▄ █▀█ █░▀█ █▄▄ ██▄   █▄▄ █▀█ █▄▄ █▄▄ █▄█ █▄▄ █▀█ ░█░ █▄█ █▀▄"""
end_message = """▀█▀ █░█ ▄▀█ █▄░█ █▄▀   █▄█ █▀█ █░█
░█░ █▀█ █▀█ █░▀█ █░█   ░█░ █▄█ █▄█
----------------------------------
LabEEE - Thermal Balance Calculator

    Developed by Zac   -    https://www.linkedin.com/in/zac-milioli
                       -    zacmilioli@gmail.com

    Created and directed by Letícia  -  https://www.linkedin.com/in/letícia-gabriela-eli-347063b0


    Texts from https://fsymbols.com/generators/blocky/
    Free of copyright
"""
warn = """█░█░█ ▄▀█ █▀█ █▄░█ █ █▄░█ █▀▀
▀▄▀▄▀ █▀█ █▀▄ █░▀█ █ █░▀█ █▄█"""
def clear_screen():
    """Limpa a tela"""
    print('\n'*150)
def separators():
    """Lê e printa os separadores da interface"""
    interface_separators = open('system/separators.txt', 'r').readlines()[0]
    print(interface_separators)
def clean_cache():
    """Limpa o cache (arquivos temporários na pasta organizer)"""
    glob_remove = glob(organizer_path+'*.csv')
    if glob_remove != []:
        for item in glob_remove:
            os.remove(item)
    