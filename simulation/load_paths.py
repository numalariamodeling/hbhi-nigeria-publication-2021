import os


def load_box_paths(user_path=None, parser_default='HPC'):

    if not user_path :
        user_path = os.path.expanduser('~')
        if 'ido0493' in user_path :
            user_path = 'C:/Users/ido0493'

    if parser_default == 'HPC':
        home_path = os.path.join(user_path, 'Box', 'NU-malaria-team')
        data_path = os.path.join(home_path, 'data')
        project_path = os.path.join(home_path, 'projects', 'hbhi_nigeria')
    else:
        project_path = '/projects/b1139/hbhi-nigeria_IO/'
        data_path = os.path.join(project_path, 'data')

    return data_path, project_path


def load_dropbox_paths(user_path=None):

    if not user_path :
        user_path = os.path.expanduser('~')
        if 'ido0493' in user_path :
            user_path = 'C:/'

    home_path = os.path.join(user_path, 'Dropbox (IDM)', 'Malaria Team Folder')
    data_path = os.path.join(home_path, 'data')
    project_path = os.path.join(home_path, 'projects')

    return data_path, project_path